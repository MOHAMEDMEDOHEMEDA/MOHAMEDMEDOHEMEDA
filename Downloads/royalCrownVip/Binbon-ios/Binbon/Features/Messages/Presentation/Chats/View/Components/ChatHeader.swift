//
//  ChatHeader.swift
//  Binbon
//

import SwiftUI

extension ChatView {

    var header: some View {
        HStack {
            HStack(spacing: 10) {
                Button { router.back() } label: {
                    Image(systemName: "chevron.backward")
                }
                avatar
                Text(viewModel.participantName)
                    .font(.system(size: 18, weight: .bold))
            }
            Spacer()
            HStack(spacing: 20) {
                Button { } label: {
                    Image(systemName: "video")
                        .font(.system(size: 18, weight: .bold))
                }
                Button { } label: {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 18, weight: .bold))
                }
                Button { } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .bold))
                }
            }
        }
        .foregroundStyle(.appText)
        .padding(.vertical, 5)
        .padding(.horizontal, 20)
        .background(AppColor.chatHeaderGradient.ignoresSafeArea(edges: .top))
    }

    var selectionHeader: some View {
        HStack {
            HStack(spacing: 10) {
                avatar
                Text(viewModel.participantName)
                    .font(.system(size: 16, weight: .bold))
            }
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isForwardMode = false
                    isDeleteMode = false
                    showDeleteConfirmation = false
                    selectedMessageIds = []
                }
            } label: {
                Text("chat_fwd_cancel".localized)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.appText)
            }
        }
        .foregroundStyle(.appText)
        .padding(.vertical, 5)
        .padding(.horizontal, 20)
        .background(AppColor.chatHeaderGradient.ignoresSafeArea(edges: .top))
    }

    var avatar: some View {
        ImageView(viewModel.participantAvatarURL, placeholder: Image(systemName: "person.fill"))
            .frame(width: 40, height: 40)
            .clipShape(Circle())
    }
}
