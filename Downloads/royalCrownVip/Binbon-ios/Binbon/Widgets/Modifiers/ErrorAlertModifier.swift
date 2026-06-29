//
//  ErrorAlertModifier.swift
//  Binbon
//
//  Created by Salah Khaled on 21/04/2026.
//

import SwiftUI

private struct ErrorAlertModifier: ViewModifier {
    
    let errorTitle: String
    @Binding var error: APIError?
    let dismissTitle: String
    let onDismiss: (() -> Void)?
    
    private var isPresented: Binding<Bool> {
        Binding(
            get: { error != nil && error?.code != 401 },
            set: { if !$0 { error = nil } }
        )
    }
    
    func body(content: Content) -> some View {
        content
            .alert(errorTitle, isPresented: isPresented) {
                Button(dismissTitle) {
                    onDismiss?()
                }
            } message: {
                Text(error?.localizedMessage() ?? "error_processing_request".localized)
            }
    }
}

extension View {
    func errorAlert(errorTitle: String = "error_title".localized,
                    error: Binding<APIError?>,
                    dismissTitle: String = "alright".localized,
                    onDismiss: (() -> Void)? = nil) -> some View {
        modifier(ErrorAlertModifier(errorTitle: errorTitle, error: error, dismissTitle: dismissTitle, onDismiss: onDismiss))
    }
}
