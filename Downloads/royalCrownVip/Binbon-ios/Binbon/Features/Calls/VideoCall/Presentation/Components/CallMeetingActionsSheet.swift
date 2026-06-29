//
//  CallMeetingActionsSheet.swift
//  Binbon
//
//  Created by Mahmoud Elsharkawy on 23/06/2026.
//

import SwiftUI

enum CallMeetingAction {
    case cameraAccess
    case closeAllVideo
    case muteAll
    case muteAllExceptOwner
    case restrictAll
    case stopScreenShare
    case report
}

struct CallMeetingActionsSheet: View {

    @Binding var isOpenMeetingMode: Bool
    @Binding var isScreenSharing: Bool
    let onAction: (CallMeetingAction) -> Void

    var body: some View {
        VStack(spacing: 0) {
            actionRow(titleKey: "voice_call_meeting_camera_access",
                      image: Image(uiImage: UIImage.hostLock),
                      action: .cameraAccess)
            divider
            actionRow(titleKey: "voice_call_meeting_close_all_video",
                      systemImage: "video.slash.fill",
                      action: .closeAllVideo)
            divider
            actionRow(titleKey: "voice_call_meeting_mute_all",
                      systemImage: "speaker.slash.fill",
                      action: .muteAll)
            divider
            actionRow(titleKey: "voice_call_meeting_mute_all_except_owner",
                      systemImage: "speaker.slash.fill",
                      action: .muteAllExceptOwner)
            divider
            actionRow(titleKey: "voice_call_meeting_restrict_all",
                      systemImage: "person.fill.xmark",
                      action: .restrictAll)

            sectionDivider

            if isScreenSharing {
                actionRow(titleKey: "voice_call_stop_screen_share",
                          systemImage: "rectangle.slash.fill",
                          action: .stopScreenShare)
            } else {
                actionRow(titleKey: "voice_call_share_screen",
                          image: Image("shareScreen"),
                          action: .stopScreenShare)
            }
            divider
            toggleRow

            sectionDivider

            actionRow(titleKey: "voice_call_meeting_report",
                      systemImage: "exclamationmark.octagon.fill",
                      action: .report,
                      isDestructive: true)
        }
        .padding(.top, 14)
        .frame(maxHeight: .infinity, alignment: .top)
        .presentationDetents([.fraction(0.62)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(27)
        .presentationBackground(AppColor.verificationGradient)
        .localizedLayout()
    }

    // MARK: - Rows

    private func actionRow(
        titleKey: String,
        systemImage: String,
        action: CallMeetingAction,
        isDestructive: Bool = false
    ) -> some View {
        Button {
            onAction(action)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 19, weight: .semibold))
                    .frame(width: 28)

                Text(titleKey.localized)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(isDestructive ? AppColor.destructive : .appText)
            .padding(.horizontal, 22)
            .frame(height: 58)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // Overload for custom assets/UIImage.
    private func actionRow(
        titleKey: String,
        image: Image,
        action: CallMeetingAction,
        isDestructive: Bool = false
    ) -> some View {
        Button {
            onAction(action)
        } label: {
            HStack(spacing: 14) {
                image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 19, height: 19)
                    .font(.system(size: 19, weight: .semibold))
                    .frame(width: 28)

                Text(titleKey.localized)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(isDestructive ? AppColor.destructive : .appText)
            .padding(.horizontal, 22)
            .frame(height: 58)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var toggleRow: some View {
        HStack(spacing: 14) {
            Text("voice_call_meeting_open_mode".localized)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: $isOpenMeetingMode)
                .labelsHidden()
                .tint(AppColor.toggleOnColor)
        }
        .padding(.horizontal, 22)
        .frame(height: 58)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.appText.opacity(0.12))
            .frame(height: 1)
            .padding(.horizontal, 22)
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(Color.appText.opacity(0.18))
            .frame(height: 1)
    }
}

// MARK: - Preview

#Preview {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            CallMeetingActionsSheet(isOpenMeetingMode: .constant(true), isScreenSharing: .constant(false)) { _ in }
        }
}
