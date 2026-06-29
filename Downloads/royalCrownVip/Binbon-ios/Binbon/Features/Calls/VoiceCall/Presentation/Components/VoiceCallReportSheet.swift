//
//  VoiceCallReportSheet.swift
//  Binbon
//

import SwiftUI

struct VoiceCallReportSheet: View {

    var titleKey: String = "voice_call_report_confirm_title"
    var messageKey: String = "voice_call_report_confirm_message"
    var confirmKey: String = "voice_call_report_yes"
    /// When set, substituted into a `%@` placeholder in the message (e.g. the user name).
    var messageArg: String? = nil
    let onConfirm: () -> Void
    let onCancel: () -> Void

    private static let sheetGradient = LinearGradient(
        colors: [Color(hex: "964E8C"), Color(hex: "E26B4E")],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                Text(titleKey.localized)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.appText)

                Text(messageArg.map { messageKey.localizedFormat($0) } ?? messageKey.localized)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.appText.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)

            VStack(spacing: 12) {
                Button {
                    onConfirm()
                } label: {
                    Text(confirmKey.localized)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColor.destructive)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    onCancel()
                } label: {
                    Text("voice_call_report_no".localized)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.appText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.appText.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 22)
        }
        .padding(.bottom, 30)
        .frame(maxHeight: .infinity, alignment: .top)
        .presentationDetents([.height(260)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(16)
        .presentationBackground(Self.sheetGradient)
        .localizedLayout()
    }
}

#Preview {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            VoiceCallReportSheet(onConfirm: {}, onCancel: {})
        }
}
