//
//  ChatViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 23/06/2026.
//

import AVFoundation
import Combine
import CoreGraphics
import Foundation
import UIKit

@MainActor
final class ChatViewModel: ObservableObject {

    enum RecordingState: Equatable {
        case idle, recording, locked
    }

    // MARK: - Chat state

    @Published var messages: [ChatMessage] = []
    @Published private(set) var pinnedIds: [UUID] = []
    @Published var composerText: String = ""
    @Published var pendingImages: [Data] = []
    @Published var pendingVideo: (url: URL, thumbnail: Data)? = nil

    // MARK: - Recording state

    @Published private(set) var recordingState: RecordingState = .idle
    @Published private(set) var recordingSeconds: Int = 0
    @Published private(set) var recordedSamples: [CGFloat] = []
    @Published private(set) var isPaused: Bool = false
    @Published var recordingDragOffset: CGSize = .zero

    // MARK: - Private

    private let loadChatThreadUseCase: LoadChatThreadUseCase
    private let conversation: MessageConversation?
    private let voiceRecorder = VoiceRecorderService()
    private var meteringTimer: AnyCancellable?
    private var secondsTimer: AnyCancellable?

    // MARK: - Init

    init(loadChatThreadUseCase: LoadChatThreadUseCase, conversation: MessageConversation? = nil) {
        self.loadChatThreadUseCase = loadChatThreadUseCase
        self.conversation = conversation
    }

    convenience init(container: AppDIContainer = .shared, conversation: MessageConversation? = nil) {
        self.init(loadChatThreadUseCase: container.makeLoadChatThreadUseCase(), conversation: conversation)
    }
 
    var participantName: String { conversation?.name ?? "" }

    // Most-recently pinned message, falling back to older pins when the latest is removed.
    var pinnedMessage: ChatMessage? {
        for id in pinnedIds.reversed() {
            if let msg = messages.first(where: { $0.id == id && $0.isPinned }) { return msg }
        }
        return nil
    }
    var participantAvatarURL: String? { conversation?.avatarURL }
    var isVerified: Bool { false }
    var recordingTimeString: String {
        let m = recordingSeconds / 60
        let s = recordingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    func setReaction(_ emoji: String, for messageId: UUID) {
        guard let idx = messages.firstIndex(where: { $0.id == messageId }) else { return }
        messages[idx].reaction = emoji
    }

    func toggleStar(_ id: UUID) {
        guard let idx = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[idx].isStarred.toggle()
    }

    func pinMessage(_ id: UUID, by pinner: ChatMessageSender = .me) {
        guard let idx = messages.firstIndex(where: { $0.id == id }) else { return }
        let wasAlreadyPinned = messages[idx].isPinned
        messages[idx].isPinned.toggle()

        if wasAlreadyPinned {
            pinnedIds.removeAll { $0 == id }
        } else {
            pinnedIds.append(id)
            let text = pinner == .me
                ? "chat_pinned_toast".localized
                : "chat_pin_other_notification".localizedFormat(participantName)
            let note = ChatMessage(
                sender: pinner,
                kind: .pinNotification,
                text: text,
                time: currentTimeString()
            )
            messages.append(note)
        }
    }

    func deleteMessages(_ ids: Set<UUID>) {
        messages.removeAll { ids.contains($0.id) }
    }

    func load() {
        Task {
            do {
                let thread = try await loadChatThreadUseCase.execute()
                messages = thread.messages
            } catch {
                messages = []
            }
        }
    }

    // MARK: - Voice recording

    func startRecording() {
        guard recordingState == .idle else { return }
        Task {
            let granted = await voiceRecorder.requestPermission()
            guard granted else { return }
            let started = voiceRecorder.startRecording()
            guard started else { return }

            recordingState = .recording
            recordingSeconds = 0
            recordedSamples = []
            isPaused = false
            recordingDragOffset = .zero
            startTimers()
        }
    }

    func lockRecording() {
        guard recordingState == .recording else { return }
        recordingState = .locked
        recordingDragOffset = .zero
    }

    func togglePause() {
        guard recordingState == .locked else { return }
        if isPaused {
            voiceRecorder.resume()
            isPaused = false
            startTimers()
        } else {
            voiceRecorder.pause()
            isPaused = true
            stopTimers()
        }
    }

    func cancelRecording() {
        stopTimers()
        voiceRecorder.cancel()
        recordingState = .idle
        recordingSeconds = 0
        recordedSamples = []
        isPaused = false
        recordingDragOffset = .zero
    }

    // Sends queued images/video (with optional caption) or a plain text message.
    func sendMessage(replyingTo: ChatMessage? = nil) {
        let caption = composerText.trimmingCharacters(in: .whitespaces)

        if !pendingImages.isEmpty, let video = pendingVideo {
            // Mixed: images + video → one combined message
            messages.append(ChatMessage(
                sender: .me,
                kind: .media(images: pendingImages, videoURL: video.url, videoThumbnail: video.thumbnail, caption: caption),
                time: currentTimeString()
            ))
            pendingImages = []
            pendingVideo = nil
            composerText = ""
        } else if !pendingImages.isEmpty {
            messages.append(ChatMessage(
                sender: .me,
                kind: .images(pendingImages, caption: caption),
                time: currentTimeString()
            ))
            pendingImages = []
            composerText = ""
        } else if let video = pendingVideo {
            messages.append(ChatMessage(
                sender: .me,
                kind: .video(url: video.url, thumbnail: video.thumbnail, caption: caption),
                time: currentTimeString()
            ))
            pendingVideo = nil
            composerText = ""
        } else if !caption.isEmpty {
            let reply = replyingTo.map {
                ChatReplyInfo(messageId: $0.id, sender: $0.sender, previewText: $0.pinPreviewText)
            }
            messages.append(ChatMessage(
                sender: .me,
                kind: .text,
                text: caption,
                time: currentTimeString(),
                replyTo: reply
            ))
            composerText = ""
        }
    }

    func sendVideo(url: URL, thumbnail: Data, caption: String = "") {
        messages.append(ChatMessage(sender: .me, kind: .video(url: url, thumbnail: thumbnail, caption: caption), time: currentTimeString()))
    }

    func sendCapturedImage(_ image: UIImage, caption: String = "") {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        messages.append(ChatMessage(sender: .me, kind: .images([data], caption: caption), time: currentTimeString()))
    }

    func sendIconImage(named: String) {
        messages.append(ChatMessage(sender: .me, kind: .iconSticker(named: named), time: currentTimeString()))
    }

    func sendSticker(emoji: String, caption: String) {
        messages.append(ChatMessage(sender: .me, kind: .sticker(emoji: emoji, caption: caption), time: currentTimeString()))
    }

    func sendLocation() {
        // Mock phase: append immediately. Swap for real GPS when API is ready.
        messages.append(ChatMessage(
            sender: .me,
            kind: .location(latitude: 24.7136, longitude: 46.6753, name: "الرياض، السعودية"),
            time: currentTimeString()
        ))
    }

    func sendContact(name: String, phone: String) {
        messages.append(ChatMessage(sender: .me, kind: .contact(name: name, phone: phone), time: currentTimeString()))
    }

    func sendDocument(name: String, size: String, url: URL) {
        messages.append(ChatMessage(sender: .me, kind: .document(name: name, size: size, url: url), time: currentTimeString()))
    }

    func sendAudio(url: URL) async {
        let asset = AVURLAsset(url: url)
        let duration: Int
        do {
            let d = try await asset.load(.duration)
            duration = max(1, Int(d.seconds))
        } catch {
            duration = 0
        }
        messages.append(ChatMessage(sender: .me, kind: .audio(url: url, duration: duration), time: currentTimeString()))
    }

    func sendVoiceMessage() {
        stopTimers()
        let url = voiceRecorder.stop()
        let samples = recordedSamples
        let duration = recordingSeconds

        let voiceMsg = ChatMessage(
            sender: .me,
            kind: .voice(url: url ?? URL(fileURLWithPath: ""), samples: samples, duration: duration),
            time: currentTimeString()
        )
        messages.append(voiceMsg)

        recordingState = .idle
        recordingSeconds = 0
        recordedSamples = []
        isPaused = false
        recordingDragOffset = .zero
    }

    // MARK: - Timers

    private func startTimers() {
        // Amplitude at 10fps for smooth waveform
        meteringTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.recordingState != .idle, !self.isPaused else { return }
                self.recordedSamples.append(self.voiceRecorder.sampleAmplitude())
            }

        // Elapsed seconds
        secondsTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.recordingState != .idle, !self.isPaused else { return }
                self.recordingSeconds += 1
            }
    }

    private func stopTimers() {
        meteringTimer?.cancel()
        meteringTimer = nil
        secondsTimer?.cancel()
        secondsTimer = nil
    }

    private func currentTimeString() -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: Date())
    }
}
