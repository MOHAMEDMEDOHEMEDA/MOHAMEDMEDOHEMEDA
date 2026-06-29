//
//  VoiceCallOwnerMenuSheet.swift
//  Binbon
//

import SwiftUI

enum VoiceCallOwnerAction {
    case muteAll
    case restrictAll
    case toggleScreenShare
    case report
}

struct VoiceCallOwnerMenuSheet: View {

    @Binding var isAllMuted: Bool
    @Binding var isAllRestricted: Bool
    @Binding var isScreenSharing: Bool
    @Binding var isOpenMeetingEnabled: Bool
    let onAction: (VoiceCallOwnerAction) -> Void

    private static let sheetGradient = LinearGradient(
        colors: [Color(hex: "964E8C"), Color(hex: "E26B4E")],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        VStack(spacing: 0) {
            actionRow(
                icon: "speaker.slash.fill",
                titleKey: isAllMuted ? "voice_call_unmute_all" : "voice_call_mute_all",
                action: .muteAll
            )
            divider
            actionRow(
                icon: "person.slash.fill",
                titleKey: isAllRestricted ? "voice_call_unrestrict_all" : "voice_call_restrict_all",
                action: .restrictAll
            )
            divider

            if isScreenSharing {
                actionRow(
                    icon: "rectangle.slash.fill",
                    titleKey: "voice_call_stop_screen_share",
                    action: .toggleScreenShare
                )
            } else {
                actionRowWithAsset(
                    assetName: "shareScreen",
                    titleKey: "voice_call_share_screen",
                    action: .toggleScreenShare
                )
            }

            divider
            toggleRow

            sectionDivider

            reportRow
        }
        .padding(.top, 14)
        .frame(maxHeight: .infinity, alignment: .top)
        .presentationDetents([.height(364)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(16)
        .presentationBackground(Self.sheetGradient)
        .localizedLayout()
    }

    // MARK: - Rows

    private func actionRow(
        icon: String,
        titleKey: String,
        action: VoiceCallOwnerAction
    ) -> some View {
        Button {
            onAction(action)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .semibold))
                    .frame(width: 28)

                Text(titleKey.localized)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(.appText)
            .padding(.horizontal, 22)
            .frame(height: 58)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func actionRowWithAsset(
        assetName: String,
        titleKey: String,
        action: VoiceCallOwnerAction
    ) -> some View {
        Button {
            onAction(action)
        } label: {
            HStack(spacing: 14) {
                Image(assetName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 19, height: 19)
                    .frame(width: 28)

                Text(titleKey.localized)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(.appText)
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

            Toggle("", isOn: $isOpenMeetingEnabled)
                .labelsHidden()
                .tint(AppColor.toggleOnColor)
        }
        .padding(.horizontal, 22)
        .frame(height: 58)
    }

    private var reportRow: some View {
        Button {
            onAction(.report)
        } label: {
            HStack(spacing: 14) {
                Image("report")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 19, height: 19)
                    .frame(width: 28)

                Text("voice_call_meeting_report".localized)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(AppColor.destructive)
            .padding(.horizontal, 22)
            .frame(height: 58)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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

#Preview {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            VoiceCallOwnerMenuSheet(
                isAllMuted: .constant(false),
                isAllRestricted: .constant(false),
                isScreenSharing: .constant(false),
                isOpenMeetingEnabled: .constant(true)
            ) { _ in }
        }
}
