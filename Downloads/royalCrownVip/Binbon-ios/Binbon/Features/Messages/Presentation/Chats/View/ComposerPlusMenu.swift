//
//  ComposerPlusMenu.swift
//  Binbon
//

import SwiftUI

enum PlusMenuAction {
    case document, camera, gallery, audio, location, contact
}

struct ComposerPlusMenu: View {

    let onAction: (PlusMenuAction) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.4))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 32)

            HStack(spacing: 0) {
                item(color: Color(hex: "2566B2"), icon: "doc.text.fill",   label: "composer_file".localized,     action: .document)
                item(color: Color(hex: "8E44AD"), icon: "camera.fill",      label: "composer_camera".localized,   action: .camera)
                item(color: Color(hex: "CB3535"), icon: "photo.fill",        label: "composer_gallery".localized,  action: .gallery)
            }
            .padding(.bottom, 28)

            HStack(spacing: 0) {
                item(color: Color(hex: "D05A16"), icon: "mic.fill",         label: "composer_audio".localized,    action: .audio)
                item(color: Color(hex: "1E8449"), icon: "mappin.circle.fill",  label: "composer_location".localized, action: .location)
                item(color: Color(hex: "138B77"), icon: "person.crop.circle.fill", label: "composer_contact".localized, action: .contact)
            }
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
        .background(AppColor.chatHeaderGradient.ignoresSafeArea(edges: .bottom))
    }

    private func item(color: Color, icon: String, label: String, action: PlusMenuAction) -> some View {
        Button { onAction(action) } label: {
            VStack(spacing: 10) {
                Circle()
                    .fill(color)
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: icon)
                            .font(.system(size: 26, weight: .medium))
                            .foregroundStyle(.white)
                    }
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
