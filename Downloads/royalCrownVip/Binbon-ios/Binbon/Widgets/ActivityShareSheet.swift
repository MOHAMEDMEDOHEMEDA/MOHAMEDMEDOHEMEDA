//
//  ActivityShareSheet.swift
//  Binbon
//
//  Thin SwiftUI wrapper around UIActivityViewController so any view can raise
//  the system share sheet (Messages, AirDrop, Copy, etc.) like a stock app.
//

import SwiftUI
import UIKit

struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension View {
    /// Presents the native iOS share sheet for the given items as a medium sheet.
    func systemShareSheet(isPresented: Binding<Bool>, items: [Any]) -> some View {
        sheet(isPresented: isPresented) {
            ActivityShareSheet(items: items)
                .presentationDetents([.medium, .large])
                .ignoresSafeArea()
        }
    }
}
