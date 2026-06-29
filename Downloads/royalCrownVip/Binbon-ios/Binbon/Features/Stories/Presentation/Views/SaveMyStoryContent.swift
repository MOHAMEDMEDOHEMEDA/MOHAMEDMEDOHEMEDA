//
//  SaveMyStoryContent.swift
//  Binbon
//
//  Created by Aya Mashaly on 17/06/2026.
//

import SwiftUI

struct SaveMyStoryContent: View {

    @StateObject private var viewModel = MyStoriesViewModel()
    @State private var showingDeleteActions = false
    @State private var tappedPill: String?

    @Environment(\.router) private var router

    var body: some View {
        VStack(spacing: 18) {
            StoryFriendsStrip(friends: viewModel.friends)

            VStack(spacing: 0) {
                tabsBar
                panel
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 40)
        .onAppear {
            viewModel.loadInitial()
            viewModel.loadSaveMyStoryDaysIfNeeded()
        }
    }

    // MARK: - Tabs
    private var tabsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(viewModel.saveMyStoryDays) { day in
                    StoryFolderTab(
                        isSelected: day.id == viewModel.activeSaveMyStoryDay?.id,
                        verticalPadding: 6,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectSaveMyStoryDay(id: day.id)
                            }
                        },
                        label: { dayLabel(day) }
                    )
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 38)
    }

    private func dayLabel(_ day: SaveMyStoryDay) -> some View {
        VStack(spacing: 1) {
            Text(day.titleKey.localized)
            if let dateText = day.dateText {
                Text(dateText)
            }
        }
        .font(.system(size: 9, weight: .bold))
        .lineLimit(1)
        .multilineTextAlignment(.center)
        .frame(minWidth: 60, minHeight: 24)
    }

    // MARK: - Panel

    private var panel: some View {
        ZStack {
            if isActiveDayDeleted {
                emptyTrashState
            } else {
                avatarAndCaption
            }
        }
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity, minHeight: 230)
        .overlay(alignment: .topLeading) {
            if !isActiveDayDeleted {
                VStack(alignment: .leading, spacing: 8) {
                    deleteStoryButton
                    if showingDeleteActions {
                        deleteMenu
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.leading, 100)
                .padding(.top, 50)
            }
        }
        .onChange(of: viewModel.activeSaveMyStoryDay?.id) { _, _ in
            showingDeleteActions = false
        }
    }

    private var isActiveDayDeleted: Bool {
        guard let id = viewModel.activeSaveMyStoryDay?.id else { return false }
        return viewModel.isSaveMyStoryDeleted(dayID: id)
    }

    private var avatarAndCaption: some View {
        Button {
            guard let active = viewModel.activeSaveMyStoryDay else { return }
            router.navigate(.storyViewer(viewerData(for: active)))
        } label: {
            VStack(spacing: 8) {
                StoryAvatar(
                    assetName: viewModel.profile?.avatarAssetName,
                    ringSize: 128,
                    imageSize: 114,
                    ringStyle: AppColor.storyRingGradient,
                    ringWidth: 3,
                    fallbackGlyphSize: 44
                )
                .padding(.top, 50)

                if let active = viewModel.activeSaveMyStoryDay {
                    VStack(spacing: 2) {
                        Text(active.captionKey.localized)
                        Text(active.bodyDateText)
                    }
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.center)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func viewerData(for day: SaveMyStoryDay) -> StoryViewerData {
        let avatar = viewModel.profile?.avatarAssetName
        let covers = [avatar, "artist_3", "artist_4"]
        return StoryViewerData(
            authorName: day.captionKey.localized,
            authorAvatarAssetName: avatar,
            items: covers.enumerated().map { index, cover in
                StoryItem(id: "\(day.id)-\(index)", coverAssetName: cover, timeAgo: day.bodyDateText)
            }
        )
    }

    private var emptyTrashState: some View {
        VStack(spacing: 12) {
            Image(systemName: "trash")
                .font(.system(size: 70, weight: .light))
                .foregroundStyle(.white.opacity(0.35))

            Text(AppStrings.saveMyStoryDeletedLabel.localized)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    private var deleteStoryButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                showingDeleteActions.toggle()
            }
        } label: {
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .font(.system(size: 16, weight: .bold))
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppStrings.saveMyStoryDelete.localized)
    }

    private var deleteMenu: some View {
        VStack(spacing: 0) {
            menuPill(
                id: "delete",
                title: AppStrings.saveMyStoryDelete.localized,
                pressedFill: AnyShapeStyle(AppColor.storyMenuDeleteGradient),
                topRadius: 14,
                bottomRadius: 0
            ) {
                if let id = viewModel.activeSaveMyStoryDay?.id {
                    viewModel.deleteSaveMyStory(dayID: id)
                }
            }
            menuPill(
                id: "cancel",
                title: "cancel".localized,
                pressedFill: AnyShapeStyle(AppColor.storyMenuCancelGradient),
                topRadius: 0,
                bottomRadius: 14
            ) {}
        }
        .frame(width: 125)
        .shadow(color: .black.opacity(0.25), radius: 2, y: 4)
    }

    private func menuPill(
        id: String,
        title: String,
        pressedFill: AnyShapeStyle,
        topRadius: CGFloat,
        bottomRadius: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            tappedPill = id
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(180))
                action()
                withAnimation(.easeInOut(duration: 0.15)) {
                    showingDeleteActions = false
                }
                tappedPill = nil
            }
        } label: {
            Text(title)
                .font(.system(size: 16))
                .shadow(color: .black.opacity(0.25), radius: 4, y: 4)
                .frame(maxWidth: .infinity)
                .frame(height: 35)
        }
        .buttonStyle(MenuPillButtonStyle(
            topRadius: topRadius,
            bottomRadius: bottomRadius,
            idleFill: AnyShapeStyle(AppColor.storyMenuPillFill),
            pressedFill: pressedFill,
            stickyPressed: tappedPill == id
        ))
    }
}

private struct MenuPillButtonStyle: ButtonStyle {

    let topRadius: CGFloat
    let bottomRadius: CGFloat
    let idleFill: AnyShapeStyle
    let pressedFill: AnyShapeStyle
    var stickyPressed: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed || stickyPressed
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: topRadius,
            bottomLeadingRadius: bottomRadius,
            bottomTrailingRadius: bottomRadius,
            topTrailingRadius: topRadius,
            style: .continuous
        )
        return configuration.label
            .background(shape.fill(pressed ? pressedFill : idleFill))
            .overlay(shape.stroke(AppColor.gold, lineWidth: 1))
            .animation(.easeInOut(duration: 0.12), value: pressed)
    }
}
