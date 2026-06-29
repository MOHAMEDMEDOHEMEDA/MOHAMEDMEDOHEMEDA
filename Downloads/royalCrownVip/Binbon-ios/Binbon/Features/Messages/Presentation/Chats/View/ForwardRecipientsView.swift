//
//  ForwardRecipientsView.swift
//  Binbon
//
//  Created by Aya Mashaly on 24/06/2026.
//

import SwiftUI

struct ForwardRecipientsView: View {
    let selectedMessageCount: Int
    let onDismiss: () -> Void
    let onForward: ([ForwardContact]) -> Void
    
    @State private var selectedIds: Set<UUID> = []
    @State private var captionText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            sheetHeader
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    contactSection(
                        title: "chat_fwd_frequent".localized,
                        contacts: ForwardContact.frequent
                    )
                    contactSection(
                        title: "chat_fwd_recent".localized,
                        contacts: ForwardContact.recent
                    )
                }
                .padding(16)
                .padding(.bottom, 80)
            }
        }
        .overlay(alignment: .bottom) { bottomBar }
        .background(AppColor.verificationGradient.ignoresSafeArea())
        .environment(\.layoutDirection, Storage.shared.language == "ar" ? .rightToLeft : .leftToRight)
        .presentationDetents([.large])
        .presentationCornerRadius(16)
        .presentationDragIndicator(.hidden)
    }
    
    // MARK: - Header
    
    private var sheetHeader: some View {
        HStack {
            Button("chat_fwd_cancel".localized) { onDismiss() }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.appText)
            
            Spacer()
            
            Button("chat_fwd_new_group".localized) {}
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.appText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Contact section
    
    private func contactSection(title: String, contacts: [ForwardContact]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColor.forwordSelectionHeader)
                .padding(.horizontal, 10)
            
            VStack(spacing: 8) {
                ForEach(contacts) { contact in
                    contactRow(contact)
                }
            }
        }
    }
    
    private func contactRow(_ contact: ForwardContact) -> some View {
        let isSelected = selectedIds.contains(contact.id)
        
        return HStack {
            HStack(spacing: 10) {
                ImageView(contact.avatarURL, placeholder: Image(systemName: "person.fill"))
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                Text(contact.name)
                    .font(.system(size: 14, weight: .semibold))
            }
            
            Spacer()
            
            selectionCircle(isSelected: isSelected)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(AppColor.verificationGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(AppColor.gold, lineWidth: 2)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                if isSelected { selectedIds.remove(contact.id) }
                else { selectedIds.insert(contact.id) }
            }
        }
    }
    
    private func selectionCircle(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .stroke(AppColor.gold, lineWidth: 2)
                .frame(width: 20, height: 20)
            
            if isSelected {
                Circle()
                    .fill(AppColor.forwordSelection)
                    .frame(width: 12, height: 12)
            }
        }
    }
    
    // MARK: - Bottom bar
    
    private var bottomBar: some View {
        VStack(spacing: 8) {
            TextField(
                "",
                text: $captionText,
                prompt: Text("chat_fwd_message_hint".localized)
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 14, weight: .bold))
            )
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.appText)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.black.opacity(0.1)))
            
            HStack {
                Button {
                    let chosen = (ForwardContact.frequent + ForwardContact.recent)
                        .filter { selectedIds.contains($0.id) }
                    onForward(chosen)
                    onDismiss()
                } label: {
                    Text("chat_fwd_forward".localized)
                        .font(.system(size: 12, weight: .bold))
                }
                .buttonStyle(.plain)
                .disabled(selectedIds.isEmpty)
                
                Spacer()
                
                Text("\("chat_fwd_selected".localized) \(selectedIds.count)")
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColor.verificationGradient)
    }
}
