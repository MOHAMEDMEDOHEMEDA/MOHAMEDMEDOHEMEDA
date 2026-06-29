//
//  ConfirmPopup.swift
//  Binbon
//

import SwiftUI

// MARK: - Confirm popup

/// A centered, two-button confirmation dialog on the brand pink→purple card.
/// Reusable anywhere via the `.confirmPopup(isPresented:…)` modifier below —
/// e.g. confirming before the share sheet hands a post off to an external app.
struct ConfirmPopup: View {
    let title: String
    var confirmTitle: String
    var cancelTitle: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 104)
                .padding(.horizontal, 24)

            Rectangle()
                .fill(AppColor.confirmPopupDivider)
                .frame(height: 2)

            HStack(spacing: 0) {
                action(cancelTitle, action: onCancel)
                Rectangle()
                    .fill(AppColor.confirmPopupDivider)
                    .frame(width: 2)
                action(confirmTitle, action: onConfirm)
            }
            .frame(height: 66)
        }
        .frame(width: 284)
        .background(AppColor.confirmPopupGradient)
        .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
    }

    private func action(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Presentation

private struct ConfirmPopupModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let confirmTitle: String
    let cancelTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    func body(content: Content) -> some View {
        content.overlay {
            if isPresented {
                ZStack {
                    AppColor.confirmPopupScrim
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture { dismiss(then: onCancel) }

                    ConfirmPopup(
                        title: title,
                        confirmTitle: confirmTitle,
                        cancelTitle: cancelTitle,
                        onConfirm: { dismiss(then: onConfirm) },
                        onCancel: { dismiss(then: onCancel) }
                    )
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: isPresented)
    }

    /// Fire the chosen action *before* tearing the popup down so callers can
    /// still read any state the dismissal would clear (e.g. the pending item).
    private func dismiss(then completion: @escaping () -> Void) {
        completion()
        isPresented = false
    }
}

extension View {

    /// Presents a centered confirmation popup over this view. The backdrop and
    /// card cover the attached view's bounds, so apply it where it can fill the
    /// screen (e.g. on a screen root or alongside a `.sheet`).
    func confirmPopup(
        isPresented: Binding<Bool>,
        title: String,
        confirmTitle: String,
        cancelTitle: String = AppStrings.cancel.localized,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void = {}
    ) -> some View {
        modifier(ConfirmPopupModifier(
            isPresented: isPresented,
            title: title,
            confirmTitle: confirmTitle,
            cancelTitle: cancelTitle,
            onConfirm: onConfirm,
            onCancel: onCancel
        ))
    }
}

#Preview {
    Color.gray
        .ignoresSafeArea()
        .confirmPopup(
            isPresented: .constant(true),
            title: AppStrings.confirmOpenApp.localizedFormat("Facebook"),
            confirmTitle: AppStrings.open.localized,
            onConfirm: {}
        )
}
