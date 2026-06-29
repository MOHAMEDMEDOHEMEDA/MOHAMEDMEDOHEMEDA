//
//  ChatActionPanels.swift
//  Binbon
//

import SwiftUI

extension ChatView {

    // MARK: - Forward bar (isForwardMode)

    var forwardBottomBar: some View {
        HStack {
            Button { showForwardSheet = true } label: {
                Image(systemName: "arrowshape.turn.up.right.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(selectedMessageIds.isEmpty)

            Spacer()

            Text("\(selectedMessageIds.count) \("chat_fwd_selected".localized)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                let text = viewModel.messages
                    .filter { selectedMessageIds.contains($0.id) }
                    .map { $0.text }
                    .joined(separator: "\n")
                shareItems = [text]
                showSystemShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(selectedMessageIds.isEmpty)
            .sheet(isPresented: $showSystemShareSheet) {
                ActivityShareSheet(items: shareItems)
                    .presentationDetents([.medium, .large])
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
        .background(AppColor.verificationGradient)
        .sheet(isPresented: $showForwardSheet) {
            ForwardRecipientsView(
                selectedMessageCount: selectedMessageIds.count,
                onDismiss: { showForwardSheet = false }
            ) { _ in
                showForwardSheet = false
                withAnimation(.easeInOut(duration: 0.2)) {
                    isForwardMode = false
                    selectedMessageIds = []
                }
            }
        }
    }

    // MARK: - Delete bar (isDeleteMode)

    var deleteBottomBar: some View {
        HStack {
            Button {
                withAnimation(.spring(duration: 0.3)) { showDeleteConfirmation = true }
            } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.appText)
            }
            .buttonStyle(.plain)
            .disabled(selectedMessageIds.isEmpty)

            Spacer()

            Text("\("chat_del_selected".localized) \(selectedMessageIds.count)")
                .font(.system(size: 12, weight: .bold))
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
        .background(AppColor.verificationGradient)
    }

    var deleteConfirmationPanel: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("chat_del_confirm_title".localized)
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { showDeleteConfirmation = false }
                } label: {
                    ZStack {
                        Circle().fill(.white.opacity(0.1)).frame(width: 24, height: 24)
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.appText)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .frame(height: 40)

            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.deleteMessages(selectedMessageIds)
                        isDeleteMode = false
                        showDeleteConfirmation = false
                        selectedMessageIds = []
                    }
                } label: {
                    Text("chat_del_for_me".localized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColor.deleteChat)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .frame(height: 32)
                        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.appText.opacity(0.1)))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(AppColor.verificationGradient)
    }

    // MARK: - Report panel

    var reportPanel: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("chat_report_title".localized)
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { showReportPanel = false }
                } label: {
                    ZStack {
                        Circle().fill(.white.opacity(0.1)).frame(width: 24, height: 24)
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.appText)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .frame(height: 40)

            VStack(spacing: 0) {
                reportButton(
                    titleKey: "chat_report_and_block",
                    icon: "nosign"
                ) { showReportPanel = false }

                Divider().background(.appText)

                reportButton(
                    titleKey: "chat_report_only",
                    icon: "exclamationmark.triangle"
                ) { showReportPanel = false }
            }
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.appText.opacity(0.1)))
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
        .background(AppColor.verificationGradient)
    }

    private func reportButton(titleKey: String, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) { action() }
        } label: {
            HStack {
                Text(titleKey.localized)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColor.deleteChat)
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(AppColor.deleteChat)
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 8)
            .frame(height: 32)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Pin duration panel

    var pinDurationPanel: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Text("chat_pin_title".localized)
                    .font(.system(size: 12, weight: .bold))
                    .multilineTextAlignment(.center)
                Spacer()
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { showPinPanel = false }
                } label: {
                    ZStack {
                        Circle().fill(.white.opacity(0.1)).frame(width: 24, height: 24)
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.appText)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .frame(height: 40)

            HStack {
                Spacer()
                Text("chat_pin_hint".localized).font(.system(size: 8, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.appText.opacity(0.1))
                    .padding(.horizontal, 16)
            )

            VStack(spacing: 0) {
                ForEach(["chat_pin_24h", "chat_pin_7d", "chat_pin_30d"], id: \.self) { key in
                    Button {
                        if let id = pinTargetId { viewModel.pinMessage(id, by: pinTargetSender) }
                        withAnimation(.easeOut(duration: 0.2)) { showPinPanel = false }
                    } label: {
                        HStack {
                            Text(key.localized).font(.system(size: 12, weight: .medium))
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .frame(height: 32)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if key != "chat_pin_30d" { Divider().background(.appText) }
                }
            }
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.appText.opacity(0.1)))
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
        .background(AppColor.verificationGradient)
    }

    // MARK: - Pin banner

    var pinBanner: some View {
        Button {
            if let id = viewModel.pinnedMessage?.id {
                scrollToMessageId = id
                withAnimation(.easeIn(duration: 0.1)) {
                    highlightedMessageId = id
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        highlightedMessageId = nil
                    }
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "pin.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.appText)

                VStack(alignment: .leading, spacing: 1) {
                    Text(viewModel.pinnedMessage?.pinPreviewText ?? "")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.appText)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .background(AppColor.chatHeaderGradient)
        .animation(.easeInOut(duration: 0.2), value: viewModel.pinnedMessage?.id)
    }

    // MARK: - Copy toast pill

    var copyToastPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(.appText)
            Text("chat_copy_toast".localized)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.appText)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Capsule().fill(AppColor.chatCopyToastGradient))
        .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        .padding(.bottom, 76)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Reply preview strip

    func replyPreview(for message: ChatMessage) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(message.sender == .me ? "chat_reply_me".localized : viewModel.participantName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppColor.chatReplySender)
                Text(message.pinPreviewText)
                    .font(.system(size: 11))
                    .foregroundStyle(.appText)
                    .lineLimit(1)
            }
            Spacer()
            HStack(spacing: 0) {
                Rectangle().fill(AppColor.chatReplySender).frame(width: 3)
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { replyingTo = nil }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.appText)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
            }
            .frame(height: 36)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(AppColor.verificationGradient)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Helpers

    func send() {
        viewModel.sendMessage(replyingTo: replyingTo)
        withAnimation(.easeOut(duration: 0.2)) { replyingTo = nil }
    }

    func showCopyToastBriefly() {
        withAnimation(.spring(duration: 0.3)) { showCopyToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) { showCopyToast = false }
        }
    }

    func handleContextAction(_ action: ChatContextAction, for message: ChatMessage) {
        switch action {
        case .reply:
            replyingTo = message
        case .forward:
            selectedMessageIds = [message.id]
            withAnimation(.easeInOut(duration: 0.2)) { isForwardMode = true }
        case .report:
            withAnimation(.spring(duration: 0.3)) { showReportPanel = true }
        case .star:
            viewModel.toggleStar(message.id)
        case .pin:
            if message.isPinned {
                viewModel.pinMessage(message.id, by: message.sender)
            } else {
                pinTargetId = message.id
                pinTargetSender = message.sender
                withAnimation(.spring(duration: 0.3)) { showPinPanel = true }
            }
        case .delete:
            selectedMessageIds = [message.id]
            withAnimation(.easeInOut(duration: 0.2)) { isDeleteMode = true }
        case .copy:
            UIPasteboard.general.string = message.text
            showCopyToastBriefly()
        default:
            break
        }
    }
}
