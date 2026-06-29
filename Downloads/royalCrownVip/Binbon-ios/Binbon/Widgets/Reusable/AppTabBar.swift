//
//  AppTabBar.swift
//  Binbon
//
//  Created by Salah Khaled on 26/04/2026.
//


import SwiftUI
import Combine

// MARK: - Tab Item Model
enum TabItem: Int, CaseIterable {
    case home, messages, create, friends, profile

    var title: String? {
        switch self {
        case .home:     "home".localized
        case .messages: "messages".localized
        case .create:   "create".localized
        case .friends:  "friends".localized
        case .profile:  "profile".localized
        }
    }

    var icon: String {
        switch self {
        case .home:     "house"
        case .messages: "ellipsis.bubble"
        case .create:   "plus"
        case .friends:  "person.2"
        case .profile:  "person"
        }
    }

    /// Custom bottom-bar icon art (from the Figma design). `nil` for the center
    /// create button, which renders the SF "plus" inside the floating FAB.
    var assetName: String? {
        switch self {
        case .home:     "tab-home"
        case .messages: "tab-messages"
        case .create:   nil
        case .friends:  "tab-friends"
        case .profile:  "tab-profile"
        }
    }

    /// Natural icon height from the design — Friends is intentionally larger.
    var iconHeight: CGFloat {
        switch self {
        case .friends:        25
        case .home, .profile: 18
        case .messages:       17
        case .create:         20
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .home: HomeView()
        case .messages: MessagesView()
        case .create:   CreateVideoView()
        case .friends:  FriendsTabView()
        case .profile:  ProfileView()
        }
    }
}

// MARK: - Gradient Colors
private let gradientStart = Color(red: 0.95, green: 0.35, blue: 0.30)
private let gradientEnd   = Color(red: 0.55, green: 0.30, blue: 0.75)
private let activeColor   = LinearGradient(colors: [Color(hex: "FBBC05"), Color(hex: "EB7048")],
                                           startPoint: .leading, endPoint: .trailing)

// MARK: - Custom Tab Bar
private struct AppTabBar: View {
    @Binding var selectedTab: TabItem
    @Binding var showCreateWheel: Bool
    // Re-render the bar on any theme switch (incl. Colored↔Dark, where the
    // device trait doesn't change) so `tabBarFill` repaints in real time.
    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            // Bar background
            barBackground

            HStack(alignment: .bottom, spacing: 0) {
                // Left side: Home, Messages
                ForEach([TabItem.home, TabItem.messages], id: \.rawValue) { tab in
                    tabButton(tab)
                }

                // Center FAB placeholder
                Spacer()
                    .frame(width: 80)

                // Right side: Friends, Profile
                ForEach([TabItem.friends, TabItem.profile], id: \.rawValue) { tab in
                    tabButton(tab)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 36)

            // Floating center button
            floatingCreateButton
                .offset(y: -70)
        }
        .frame(height: 80)
    }

    // MARK: - Bar Background
    private var barBackground: some View {
        CutoutShape()
            .fill(AppColor.tabBarFill)
            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: -4)
    }

    // MARK: - Tab Icon (custom Figma art, tinted via the row's foregroundStyle)
    @ViewBuilder
    private func tabIcon(_ tab: TabItem) -> some View {
        if let asset = tab.assetName {
            Image(asset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: tab.iconHeight)
        } else {
            Image(systemName: tab.icon)
                .font(.body.weight(.medium))
        }
    }

    // MARK: - Regular Tab Button
    @ViewBuilder
    private func tabButton(_ tab: TabItem) -> some View {
        let isSelected = selectedTab == tab

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                tabIcon(tab)
                    .frame(height: 26, alignment: .bottom)

                if let title = tab.title {
                    Text(title)
                        .font(.caption.weight(.medium))
                }

                /// Active indicator line
                if isSelected {
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 30, height: 3)
                        .padding(.top, 2)
                } else {
                    Color.clear
                        .frame(width: 30, height: 3)
                        .padding(.top, 2)
                }
            }
            .foregroundStyle(isSelected ? activeColor : LinearGradient(colors: [Color.appText.opacity(0.85)],
                                                                       startPoint: .leading, endPoint: .trailing))
            .frame(maxWidth: .infinity)
            .padding(.top, 14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Floating "+" Button (morphs into an X while the wheel is open)
    private var floatingCreateButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showCreateWheel.toggle()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppColor.tabBarFill)
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(45))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)

                Image(systemName: showCreateWheel ? "xmark" : TabItem.create.icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(showCreateWheel ? activeColor : LinearGradient(colors: [.appText.opacity(0.85)],
                                                                                    startPoint: .leading, endPoint: .trailing))
                    .rotationEffect(.degrees(showCreateWheel ? 90 : 0))
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(showCreateWheel ? 1.08 : 0.9)
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: showCreateWheel)
        .zIndex(10)
    }
}

// MARK: - Cutout Shape (notch in bar for FAB)
private struct CutoutShape: Shape {
    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let notchWidth: CGFloat = 114
        let notchDepth: CGFloat = 41
        let cornerRadius: CGFloat = 20
        let curveWidth: CGFloat = 18
        
        var path = Path()
        
        /// Top-left corner
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        path.addLine(to: CGPoint(x: midX - notchWidth / 2, y: 0))
        
        /// Left wall: enter nearly vertically, curve into the bottom
        path.addCurve(
            to: CGPoint(x: midX, y: notchDepth),
            control1: CGPoint(x: midX - notchWidth / 2 + curveWidth, y: 0),
            control2: CGPoint(x: midX - curveWidth, y: notchDepth)
        )
        
        /// Right wall: mirror
        path.addCurve(
            to: CGPoint(x: midX + notchWidth / 2, y: 0),
            control1: CGPoint(x: midX + curveWidth, y: notchDepth),
            control2: CGPoint(x: midX + notchWidth / 2 - curveWidth, y: 0)
        )
        
        /// Top-right corner
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: cornerRadius),
            control: CGPoint(x: rect.maxX, y: 0)
        )
        
        /// Right side & bottom
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Reel chrome state

/// Lets the immersive Reels screen hide the global tab bar in sync with its own
/// auto-hiding overlay chrome (single tap toggles both).
final class ReelChromeState: ObservableObject {
    static let shared = ReelChromeState()
    /// Drives the reel overlay chrome and the app tab bar together. Shared (not
    /// per-cell) so the hidden state survives swiping between reels and pausing.
    @Published var chromeVisible = true
    /// True while the reels host (Home tab) is the active app tab. Reels pause
    /// their video whenever this turns false (switching to another tab).
    @Published var hostActive = true
    private init() {}
}

// MARK: - AppTabBar View
struct AppTabBarView: View {

    @State private var tab: TabItem = .home
    @State private var showCreateWheel = false
    @State private var showNewPost = false
    @ObservedObject private var reelChrome = ReelChromeState.shared

    var body: some View {
        ZStack {
            // Keep every tab alive and only reveal the selected one, so each
            // screen's scroll position and in-flight state survive switches.
            ForEach(TabItem.allCases, id: \.rawValue) { item in
                tabContent(item)
                    .screenLoading(isActive: tab == item)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(tab == item ? 1 : 0)
                    .zIndex(tab == item ? 1 : 0)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: tab)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Wheel sits under the tab bar so the create button (rendered by the bar's
        // safeAreaInset, below) stays on top and morphs into the X pivot.
        .overlay {
            CreateWheelMenu(isShown: $showCreateWheel) { option in
                // The pencil opens the post composer; the rest route to create.
                if option == .edit {
                    showNewPost = true
                } else {
                    tab = .create
                }
            }
        }
        .fullScreenCover(isPresented: $showNewPost) {
            NewPostView { _, _ in
                Toaster.shared.show(.success("checkmark.circle.fill"), "new_post".localized)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            // The create screen is full-screen — hide the tab bar there. Reels
            // also hides it while its chrome is tapped away, but only on the Home
            // tab — switching to another tab must always keep the bar visible.
            if tab != .create && (tab != .home || reelChrome.chromeVisible) {
                AppTabBar(selectedTab: $tab, showCreateWheel: $showCreateWheel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: reelChrome.chromeVisible)
        .onChange(of: tab) { _, newTab in
            // Tell the reels host whether it's the active tab so it can pause/resume.
            reelChrome.hostActive = (newTab == .home)
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
    }

    /// Special-cases the create tab so its close button returns to Home.
    @ViewBuilder
    private func tabContent(_ item: TabItem) -> some View {
        if item == .create {
            CreateVideoView(onClose: { withAnimation { tab = .home } })
        } else {
            item.view
        }
    }
}

// MARK: - Preview
#Preview {
    AppTabBarView()
}



#warning("Remove")
struct DummyView: View {
    
    
    let title: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(title)
                .foregroundStyle(.appText)
            Spacer()
        }
        .appBackground()
        .toolbar(.hidden, for: .navigationBar)
    }
}
