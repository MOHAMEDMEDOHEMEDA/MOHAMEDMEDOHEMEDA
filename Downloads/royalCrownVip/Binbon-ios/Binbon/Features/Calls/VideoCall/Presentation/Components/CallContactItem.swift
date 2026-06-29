//
//  CallContactItem.swift
//  Binbon
//

import SwiftUI

/// One row in the "Add Participant" drawer — avatar, name, trailing '+' button.
struct CallContactItem: View {

    let contact: CallContact
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            avatar

            Text(contact.displayName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 2, y: 2)
                .lineLimit(1)

            Spacer(minLength: 0)

            addButton
        }
        .padding(.horizontal, 14)
        .frame(height: 56)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.10))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppColor.gold.opacity(0.55), lineWidth: 1)
                }
        }
    }

    // MARK: - Subviews

    private var avatar: some View {
        Group {
            if let urlStr = contact.avatarURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        placeholderCircle
                    }
                }
            } else {
                placeholderCircle
            }
        }
        .frame(width: 45, height: 45)
        .clipShape(Circle())
        .overlay(Circle().stroke(AppColor.gold, lineWidth: 1.5))
    }

    private var placeholderCircle: some View {
        Circle().fill(.white.opacity(0.25))
    }

    private var addButton: some View {
        Button(action: onAdd) {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Circle().fill(.white.opacity(0.20)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("voice_call_add_person".localized)
    }
}
