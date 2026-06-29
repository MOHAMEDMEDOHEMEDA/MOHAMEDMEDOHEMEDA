//
//  ProfileView.swift
//  Binbon
//
//  Created by Salah Khaled on 26/04/2026.
//

import SwiftUI

struct ProfileView: View {
    
    // MARK: Properties
    @Environment(\.router) private var router
    @State private var expandedHeight: CGFloat = 300
    @State private var collapsedHeight: CGFloat = 90
    @State private var scrollOffset: CGFloat = 0
    
    @State private var avatarTimer: Timer? = nil
    @State private var currentAvatarIndex: Int = 0
    @State private var currentAvatarImage: UIImage? = nil
    
    private var collapseThreshold: CGFloat { expandedHeight * 0.5 }
    private var collapseProgress: CGFloat { min(max(scrollOffset / collapseThreshold, 0), 1) }
    
    @StateObject var viewModel = ProfileViewModel()
    @State var selectedTab = 0
    @State private var showAccountSwitcher = false
    
    
    // MARK: Body
    var body: some View {
        ZStack(alignment: .top) {
            profileContent
            profileHeader
        }
        .appBackground()
        .appNavigation(title: "profile".localized)
        .errorAlert(error: $viewModel.error)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showAccountSwitcher) {
            AccountSwitcherSheet(
                name: viewModel.user?.fullname ?? "",
                username: viewModel.user?.username ?? "",
                avatarURL: viewModel.user?.profilePhoto,
                onAddAccount: {
                    // TODO: multi-account add flow — no spec yet.
                },
                onLogout: {
                    showAccountSwitcher = false
                    Storage.shared.logout()
                    router.root(.authSelection)
                }
            )
            .presentationDetents([.height(265)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
            .presentationBackground(AppColor.backgroundGradient)
        }
        .task {
            viewModel.fetchUserDetails()
        }
        .onChange(of: viewModel.avatarList) {
            startAvatarCycling()
        }
        .onDisappear {
            avatarTimer?.invalidate()
            avatarTimer = nil
        }
    }
    
    // MARK: Profile Content
    @ViewBuilder
    private var profileContent: some View {
        ProfileScrollContent(selectedTab: $selectedTab, headerSpacerHeight: expandedHeight)
            .onPreferenceChange(ProfileScrollOffsetKey.self) { value in
                scrollOffset = max(value, 0)
            }
    }

    // MARK: - Profile Header
    @ViewBuilder
    private var profileHeader: some View {
        let currentHeight = max(expandedHeight - scrollOffset, collapsedHeight)
        
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    expandedHeader
                        .opacity(
                            (collapseProgress < 0.5)
                            ? Double(1 - (collapseProgress * 2))
                            : 0.0
                        )
                    
                    collapsedHeader
                        .opacity(
                            (collapseProgress >= 0.5)
                            ? Double((collapseProgress - 0.5) * 2)
                            : 0.0
                        )
                }
            }
            .frame(height: currentHeight)
        }
        .frame(maxWidth: .infinity)
        .background(
            // Transparent while expanded so the header shares the screen's
            // gradient (no seam); only fades in opaquely once collapsed, to
            // hide the content scrolling beneath the sticky bar.
            Rectangle()
                .fill(AppColor.profileHeaderFill)
                .opacity(collapseProgress)
                .ignoresSafeArea(edges: .top)
        )
        .onPreferenceChange(ExpandedHeightKey.self) { height in
            if height > 0 { expandedHeight = height + 16 }
        }
        .onPreferenceChange(CollapsedHeightKey.self) { height in
            if height > 0 { collapsedHeight = height + 10 }
        }
    }

    // MARK: - Expanded Header
    private var expandedHeader: some View {
        
        VStack(spacing: 20) {
            HStack(alignment: .center, spacing: 16) {
                /// Profile Image
                photoSection
                
                /// title
                titleSection
                
                Spacer()
                
                settingButton
                    .padding(.bottom)
            }
            
            /// Social Media
            socialMediaSection
            
            /// Bio
            bioSection
            
            /// Stats row
            statSection
            
            /// Actions
            actionSection
        }
        .padding(.bottom, 20)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: ExpandedHeightKey.self, value: geo.size.height)
            }
        )
    }
    
    // MARK: - Collapsed Header
    private var collapsedHeader: some View {
        HStack(alignment: .center, spacing: 14) {
            /// Profile Image
            photoSection
            
            /// title
            titleSection
            
            Spacer()
            
            HStack(spacing: 8) {
                /// Actions
                actionSection
                
                /// Setting
                settingButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 14)
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: CollapsedHeightKey.self, value: geo.size.height)
            }
        )
    }
    
    // MARK: - Photo
    private var photoSection: some View {
        let isExpanded = collapseProgress < 0.5
        let size: CGFloat = isExpanded ? 70 : 44
        let cornerRadius: CGFloat = isExpanded ? 16 : 10
        
        return Group {
            // Auto-cycle the profile photo whenever there's more than one avatar.
            if viewModel.avatarList.count > 1 {
                ProfileImageView.widget(image: currentAvatarImage, size: size, cornerRadius: cornerRadius)
                    .id(currentAvatarIndex)
                    .transition(.opacity)
            } else {
                ProfileImageView(viewModel: viewModel.imagePicker, size: size, cornerRadius: cornerRadius)
            }
        }
    }
    
    @MainActor
    private func startAvatarCycling() {
        // Always cancel any running timer first so repeated calls don't stack.
        avatarTimer?.invalidate()
        avatarTimer = nil

        guard viewModel.avatarList.count > 1 else {
            currentAvatarIndex = 0
            currentAvatarImage = nil
            return
        }

        currentAvatarIndex = 0

        Task { @MainActor in
            /// Preload all avatars
            await withTaskGroup(of: Void.self) { group in
                for avatar in viewModel.avatarList {
                    group.addTask { _ = await Network.shared.image(avatar.url ?? "") }
                }
            }
            
            /// Set first image
            currentAvatarImage = await Network.shared.image(viewModel.avatarList[0].url ?? "")
            
            /// Start Cycling
            avatarTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
                Task { @MainActor in
                    let next = (currentAvatarIndex + 1) % viewModel.avatarList.count
                    // Preload the next frame (already cached from the warm-up
                    // above) so the crossfade swaps to a ready image, never a blank.
                    let image = await Network.shared.image(viewModel.avatarList[next].url ?? "")
                    withAnimation(.easeInOut(duration: 0.7)) {
                        currentAvatarIndex = next
                        currentAvatarImage = image
                    }
                }
            }
        }
    }
    
    // MARK: - Title
    private var titleSection: some View {
        
        let isExpanded = collapseProgress < 0.5
        
        return VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                verifyImage
                
                Text(viewModel.user?.fullname ?? "")
                    .font(isExpanded ? .title3.bold() : .callout.bold())
                    .foregroundColor(.appText)
                if isExpanded {
                    Button {
                        showAccountSwitcher = true
                    } label: {
                        Image(systemName: showAccountSwitcher ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.appText)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Text("@\(viewModel.user?.username ?? "")")
                .font(isExpanded ? .subheadline.weight(.medium) : .caption.weight(.medium))
                .foregroundColor(.appText.opacity(0.8))
                .minimumScaleFactor(0.9)
            
            Text("binbon_id".localizedFormat(viewModel.user?.identity ?? ""))
                .font(isExpanded ? .footnote : .caption2)
                .foregroundColor(.appText.opacity(0.8))
                .minimumScaleFactor(0.9)
        }
        .lineLimit(1)
    }
    
    // MARK: - Verify
    private var verifyImage: some View {
        Group {
            if #available(iOS 18.0, *) {
                ZStack(alignment: .center) {
                    Image(systemName: "checkmark.seal")
                        .foregroundStyle(.appText)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(viewModel.user?.isVerify == 1 ? .blue : .gray)
                }
                .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 2.0)))
                
            } else {
                ZStack(alignment: .center) {
                    Image(systemName: "checkmark.seal")
                        .foregroundStyle(.appText)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(viewModel.user?.isVerify == 1 ? .blue : .gray)
                }
            }
        }
        .frame(width: 20, height: 20, alignment: .center)
        .font(.headline.weight(.bold))
        .onTapGesture {
            if viewModel.user?.isVerify != 1 {
                router.navigate(.verification)
            }
        }
    }
    
    
    // MARK: - Setting
    private var settingButton: some View {
        Button {
            router.navigate(.profileSetting)
        } label: {
            Image(.profileMenu)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.primary) // dynamic color
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .padding(2)
    }
    
    // MARK: - Social Media Section
    private var socialMediaSection: some View {
        
        let iconSize: CGFloat = 16
        
        let platformIconMap: [(platform: String, icon: String)] = [
            ("instagram", "profile-instagram"),
            ("thread",    "profile-thread"),
            ("facebook",  "profile-facebook"),
            ("x",         "profile-x"),
            ("youtube",   "profile-youtube"),
            ("tiktok",    "profile-tiktok"),
            ("snapchat",  "profile-snapchat"),
            ("whatsapp",  "profile-whatsapp")
        ]
        
        return HStack(spacing: 6) {
            ForEach(platformIconMap, id: \.icon) { item in
                
                let link = viewModel.user?.socialLinks?.first {
                    $0.title?.lowercased() == item.platform.lowercased()
                }
                
                Button {
                    if let urlString = link?.url,
                       let url = URL(string: urlString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Image(item.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                }
                .buttonStyle(.plain)
                .padding(4)
                .background(.appSurface, in: Capsule())
                .opacity(link == nil ? 0.5 : 1)
                .disabled(link == nil)
            }
            
            Spacer()
            
            Button {
                
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.user?.zodiac ?? "")
                        .font(.caption)
                        .lineLimit(0)
                        .foregroundStyle(.appText)
                        .kerning(-0.15)
                    
                    ImageView(viewModel.user?.zodiacImageUrl, tint: .appText)
                        .frame(width: iconSize, height: iconSize)

                }
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Stats Section
    private var statSection: some View {
        let stats: [(String, Int, () -> Void)] = [
            ("friends".localized, viewModel.user?.friendsCount ?? 0, {
                router.navigate(.follow(.friends))
            }),
            ("following".localized, viewModel.user?.followingCount ?? 0, {
                router.navigate(.follow(.following))
            }),
            ("followers".localized, viewModel.user?.followerCount ?? 0, {
                router.navigate(.follow(.followers))
            }),
            ("likes".localized, viewModel.user?.totalPostLikesCount ?? 0, {
                router.navigate(.follow(.likes))
            }),
        ]
        
        return HStack(spacing: 2) {
            ForEach(stats, id: \.0) { key, value, action in
                Button{
                    action()
                } label: {
                    VStack {
                        Text(key)
                            .font(.caption)
                        Text("\(value)")
                            .font(.footnote.weight(.semibold))
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Actions
    private var actionSection: some View {
        
        let isExpanded = collapseProgress < 0.5
        
        let actions: [(String, String, () -> Void)] = [
            ("edit_profile".localized, "pencil.line", {
                router.navigate(.editProfile)
            }),
            ("share_profile".localized, "square.and.arrow.up", {
                router.navigate(.shareProfile)
            }),
            ("find_friends".localized, "person.badge.plus", {
                router.navigate(.findFriend)
            }),
        ]
        
        return HStack(spacing: isExpanded ? 10 : 6) {
            Group {
                ForEach(actions, id: \.0) { key, value, action in
                    Button {
                        action()
                    } label: {
                        if isExpanded {
                            Text(key)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .padding(.horizontal, 4)
                                .frame(maxWidth: .infinity)
                        } else {
                            Image(systemName: value)
                                .frame(width: 14, height: 14)
                                .padding(.horizontal, 8)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
            }
            .font(.subheadline)
            .padding(.all, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppColor.goldAccentGradient, lineWidth: 1.5)
            )
        }
        .foregroundStyle(.appText)
    }
    
    // MARK: - Bio
    private var bioSection: some View {
        
        guard let bio = viewModel.user?.bio else { return AnyView(EmptyView()) }
        
        return AnyView(
            HStack {
                Text(bio)
                    .font(.footnote)
                    .foregroundStyle(.appText)
                    .lineLimit(1)
                Spacer()
            }
        )
    }
    
    // MARK: - Preference Key
    private struct ExpandedHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    private struct CollapsedHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
