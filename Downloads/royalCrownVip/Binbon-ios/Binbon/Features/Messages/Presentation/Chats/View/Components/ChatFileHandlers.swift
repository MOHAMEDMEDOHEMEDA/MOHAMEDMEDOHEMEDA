//
//  ChatFileHandlers.swift
//  Binbon
//

import Contacts
import ContactsUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers

// MARK: - ChatView file-handling helpers

extension ChatView {

    func handlePlusAction(_ action: PlusMenuAction) {
        switch action {
        case .document: showDocumentPicker = true
        case .audio:    showAudioPicker = true
        case .location: showLocationConfirm = true
        case .camera:   showChatCamera = true
        case .gallery:  showGalleryFromPlusSheet = true
        case .contact:  showContactPicker = true
        }
    }

    func handleDocumentURL(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        let name = url.lastPathComponent
        let bytes = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
        let size = ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
        let dest = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + "_" + name)
        guard (try? FileManager.default.copyItem(at: url, to: dest)) != nil else { return }
        viewModel.sendDocument(name: name, size: size, url: dest)
    }

    func handleAudioURL(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        let dest = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + "_" + url.lastPathComponent)
        guard (try? FileManager.default.copyItem(at: url, to: dest)) != nil else { return }
        Task { await viewModel.sendAudio(url: dest) }
    }
}

// MARK: - DocumentPickerHost
//
// .fileImporter silently drops presentations inside NavigationStack on iOS 17.
// This representable presents UIDocumentPickerViewController from the topmost
// UIViewController, bypassing SwiftUI's sheet mechanism entirely.

struct DocumentPickerHost: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let types: [UTType]
    let onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIViewController { UIViewController() }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard isPresented, context.coordinator.active == nil else { return }
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        context.coordinator.active = picker
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  var top = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
            else { return }
            while let next = top.presentedViewController { top = next }
            top.present(picker, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(isPresented: $isPresented, onPick: onPick) }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var isPresented: Bool
        let onPick: (URL) -> Void
        weak var active: UIDocumentPickerViewController?

        init(isPresented: Binding<Bool>, onPick: @escaping (URL) -> Void) {
            _isPresented = isPresented
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            active = nil
            isPresented = false
            guard let url = urls.first else { return }
            onPick(url)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            active = nil
            isPresented = false
        }
    }
}

// MARK: - ContactPickerHost

struct ContactPickerHost: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onPick: (String, String) -> Void

    func makeUIViewController(context: Context) -> UIViewController { UIViewController() }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard isPresented, context.coordinator.active == nil else { return }
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        context.coordinator.active = picker
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  var top = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
            else { return }
            while let next = top.presentedViewController { top = next }
            top.present(picker, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(isPresented: $isPresented, onPick: onPick) }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        @Binding var isPresented: Bool
        let onPick: (String, String) -> Void
        weak var active: CNContactPickerViewController?

        init(isPresented: Binding<Bool>, onPick: @escaping (String, String) -> Void) {
            _isPresented = isPresented
            self.onPick = onPick
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            active = nil
            isPresented = false
            let name = CNContactFormatter.string(from: contact, style: .fullName) ?? contact.givenName
            let phone = contact.phoneNumbers.first?.value.stringValue ?? ""
            onPick(name, phone)
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            active = nil
            isPresented = false
        }
    }
}
