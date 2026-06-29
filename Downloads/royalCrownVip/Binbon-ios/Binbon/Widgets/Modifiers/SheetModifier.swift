//
//  StyledSheetModifier.swift
//  Binbon
//
//  Created by Aya Mashaly on 09/06/2026.
//

import SwiftUI

struct SheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var detents: Set<PresentationDetent> = [.medium, .large]
    var showsIndicator: Bool = true
    var cornerRadius: CGFloat = 24
    let onDismiss: (() -> Void)?
    @ViewBuilder let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                sheetContent()
                    .presentationDetents(detents)
                    .presentationDragIndicator(showsIndicator ? .visible : .hidden)
                    .presentationCornerRadius(cornerRadius)
            }
    }
}

extension View {
    func sheetView<SheetContent: View>(isPresented: Binding<Bool>,
                                       detents: Set<PresentationDetent> = [.medium, .large],
                                       showsIndicator: Bool = true,
                                       cornerRadius: CGFloat = 24,
                                       onDismiss: (() -> Void)? = nil,
                                       @ViewBuilder content: @escaping () -> SheetContent) -> some View {
        modifier(
            SheetModifier(
                isPresented: isPresented,
                detents: detents,
                showsIndicator: showsIndicator,
                cornerRadius: cornerRadius,
                onDismiss: onDismiss,
                sheetContent: content
            )
        )
    }
}

extension View {

    func sheetNavigation(
        title: String,
        cancelTitle: String = "cancel".localized,
        saveTitle: String = "save".localized,
        closeImage: String = "xmark",

        showCancel: Bool = false,
        showSave: Bool = false,
        showClose: Bool = false,
        hideBackButton: Bool = false,

        isSaveEnabled: Bool = true,

        onCancel: (() -> Void)? = nil,
        onSave: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) -> some View {

        self
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(hideBackButton)
            .toolbar {

                if showCancel, let onCancel {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(cancelTitle, action: onCancel)
                    }
                }

                if showSave, let onSave {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(saveTitle, action: onSave)
                            .foregroundStyle(
                                isSaveEnabled
                                ? AppColor.accentRed
                                : Color(.systemGray3)
                            )
                            .disabled(!isSaveEnabled)
                    }
                }

                if showClose, let onClose {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: onClose) {
                            Image(systemName: closeImage)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
            }
    }
}

struct FullDismissKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var fullDismiss: (() -> Void)? {
        get { self[FullDismissKey.self] }
        set { self[FullDismissKey.self] = newValue }
    }
}
