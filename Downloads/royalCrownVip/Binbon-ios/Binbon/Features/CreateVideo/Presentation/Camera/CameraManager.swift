//
//  CameraManager.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import SwiftUI
import Combine

final class CameraManager: NSObject, ObservableObject {

    // MARK: - Published state
    @Published private(set) var isAuthorized = false
    @Published private(set) var isRecording = false
    @Published private(set) var isTorchOn = false
    @Published private(set) var flashEnabled = false
    @Published private(set) var position: AVCaptureDevice.Position = .back
    @Published private(set) var lastRecordingURL: URL?
    @Published private(set) var recordingElapsed: Double = 0
    @Published private(set) var zoomFactor: CGFloat = 1
    @Published var isMuted = false
    @Published var isFlipping = false

    // MARK: - Segments (TikTok-style multi-take recording)
    @Published private(set) var segments: [URL] = []
    @Published private(set) var segmentDurations: [Double] = []
    @Published private(set) var segmentTakes: [Int] = []
    @Published private(set) var totalRecordedDuration: Double = 0
    @Published private(set) var currentTake = 0

    var recordingSeconds: Int { Int(recordingElapsed) }
    var totalRecordedSeconds: Int { Int(totalRecordedDuration) }
    var hasSegments: Bool { !segments.isEmpty }

    @Published var maxSeconds: Int = 60
    private var timer: Timer?

    private var nextIsNewTake = true
    private var activeTake = 0
    private var resumeAfterFlip = false

    // MARK: - Capture
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "binbon.camera.session")
    private var videoInput: AVCaptureDeviceInput?
    private let movieOutput = AVCaptureMovieFileOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private var photoDelegate: PhotoCaptureDelegate?
    private var isConfigured = false

    // MARK: - Lifecycle
    func start() async {
        let granted = await requestAuthorization()
        guard granted else {
            await MainActor.run { self.isAuthorized = false }
            return
        }

        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configureIfNeeded()
            let audio = AVAudioSession.sharedInstance()
            try? audio.setCategory(.playAndRecord,
                                   options: [.mixWithOthers, .defaultToSpeaker])
            try? audio.setActive(true)
            if !self.session.isRunning { self.session.startRunning() }
            // Flip the published flag only once the session is configured AND running.
            // The preview layer is created the instant `isAuthorized` is true, and
            // attaching a layer to a session that's still inside `beginConfiguration`
            // on this queue blocks the main thread (camera-on / call re-enter freeze).
            DispatchQueue.main.async { self.isAuthorized = true }
        }
    }

    func stop() {
        // Capture the session/output directly (they're `let`) instead of `self`, so the
        // teardown still runs when the owning manager is being deallocated — e.g. when a
        // call view disappears. A `[weak self]` here can be nil by the time the block runs,
        // leaving the session running and holding the camera, which freezes the next call.
        sessionQueue.async { [session, movieOutput] in
            guard session.isRunning else { return }
            if movieOutput.isRecording { movieOutput.stopRecording() }
            session.stopRunning()
        }
    }

    deinit {
        // Safety net: guarantees the camera is released if the owning view is torn
        // down without an explicit `stop()` (e.g. an interrupted navigation pop).
        stop()
    }

    private func requestAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return true
        case .notDetermined: return await AVCaptureDevice.requestAccess(for: .video)
        default: return false
        }
    }

    // MARK: - Configuration
    private func configureIfNeeded() {
        guard !isConfigured else { return }
        isConfigured = true

        session.automaticallyConfiguresApplicationAudioSession = false
        let audio = AVAudioSession.sharedInstance()
        try? audio.setCategory(.playAndRecord,
                               options: [.mixWithOthers, .defaultToSpeaker])
        try? audio.setActive(true)

        session.beginConfiguration()
        session.sessionPreset = .high

        if let device = camera(for: position),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
            videoInput = input
        }

        if let mic = AVCaptureDevice.default(for: .audio),
           let input = try? AVCaptureDeviceInput(device: mic),
           session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()
    }

    private func camera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        ).devices.first
    }

    // MARK: - Flip
    func flipCamera() {
        if movieOutput.isRecording {
            isFlipping = true
            resumeAfterFlip = true
            stopRecording()
        } else {
            sessionQueue.async { [weak self] in self?.swapCameraInput() }
        }
    }

    private func swapCameraInput() {
        let newPosition: AVCaptureDevice.Position = (position == .back) ? .front : .back
        guard let device = camera(for: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: device) else { return }

        session.beginConfiguration()
        if let current = videoInput { session.removeInput(current) }
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            videoInput = newInput
        }
        session.commitConfiguration()

        DispatchQueue.main.async {
            self.position = newPosition
            if newPosition == .front { self.isTorchOn = false }
        }
    }

    // MARK: - Flash / mute
    func toggleFlash() {
        flashEnabled.toggle()
        if !flashEnabled { setTorch(false) }
    }

    private func setTorch(_ on: Bool) {
        sessionQueue.async { [weak self] in
            guard let self,
                  let device = self.videoInput?.device,
                  device.hasTorch, device.isTorchAvailable else { return }
            do {
                try device.lockForConfiguration()
                device.torchMode = on ? .on : .off
                device.unlockForConfiguration()
                DispatchQueue.main.async { self.isTorchOn = on }
            } catch { /* torch unavailable */ }
        }
    }

    func toggleMute() { isMuted.toggle() }

    // MARK: - Photo
    func capturePhoto(_ completion: @escaping (UIImage?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self, self.session.outputs.contains(self.photoOutput) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            if let connection = self.photoOutput.connection(with: .video),
               connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = (self.position == .front)
            }
            let delegate = PhotoCaptureDelegate { image in
                DispatchQueue.main.async { completion(image) }
            }
            self.photoDelegate = delegate
            self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: delegate)
        }
    }

    // MARK: - Recording
    func startRecording() {
        nextIsNewTake = true
        beginCapture()
    }

    private func beginCapture() {
        sessionQueue.async { [weak self] in
            guard let self, !self.movieOutput.isRecording else { return }
            self.movieOutput.connection(with: .audio)?.isEnabled = !self.isMuted

            if let videoConnection = self.movieOutput.connection(with: .video),
               videoConnection.isVideoMirroringSupported {
                videoConnection.automaticallyAdjustsVideoMirroring = false
                videoConnection.isVideoMirrored = (self.position == .front)
            }

            if self.flashEnabled,
               let device = self.videoInput?.device,
               device.hasTorch, device.isTorchAvailable {
                try? device.lockForConfiguration()
                device.torchMode = .on
                device.unlockForConfiguration()
                DispatchQueue.main.async { self.isTorchOn = true }
            }

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            self.movieOutput.startRecording(to: url, recordingDelegate: self)
        }
    }

    func stopRecording() {
        sessionQueue.async { [weak self] in
            guard let self, self.movieOutput.isRecording else { return }
            self.movieOutput.stopRecording()
        }
    }

    // MARK: - Zoom
    func setZoom(_ factor: CGFloat) {
        sessionQueue.async { [weak self] in
            guard let self, let device = self.videoInput?.device else { return }
            let maxZoom = min(device.maxAvailableVideoZoomFactor, 8)
            let clamped = max(device.minAvailableVideoZoomFactor, min(factor, maxZoom))
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = clamped
                device.unlockForConfiguration()
                DispatchQueue.main.async { self.zoomFactor = clamped }
            } catch { /* ignore */ }
        }
    }

    // MARK: - Recording timer (≈30 fps for a smooth, dynamic ring)
    private func startTimer() {
        recordingElapsed = 0
        timer?.invalidate()
        let interval = 1.0 / 30.0
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.recordingElapsed += interval
            if self.totalRecordedDuration + self.recordingElapsed >= Double(self.maxSeconds) {
                self.stopRecording()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Segment management
    func reset() {
        segments.removeAll()
        segmentDurations.removeAll()
        segmentTakes.removeAll()
        totalRecordedDuration = 0
        recordingElapsed = 0
        currentTake = 0
        lastRecordingURL = nil
    }

    func mergeSegments() async -> URL? {
        guard !segments.isEmpty else { return nil }
        if segments.count == 1 { return segments[0] }

        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: .video,
                                                     preferredTrackID: kCMPersistentTrackID_Invalid)
        var audioTrack: AVMutableCompositionTrack?
        var cursor = CMTime.zero
        var transformSet = false

        for url in segments {
            let asset = AVURLAsset(url: url)
            guard let duration = try? await asset.load(.duration), duration.seconds > 0 else { continue }
            let range = CMTimeRange(start: .zero, duration: duration)

            if let v = try? await asset.loadTracks(withMediaType: .video).first {
                try? videoTrack?.insertTimeRange(range, of: v, at: cursor)
                if !transformSet, let t = try? await v.load(.preferredTransform) {
                    videoTrack?.preferredTransform = t
                    transformSet = true
                }
            }
            if let a = try? await asset.loadTracks(withMediaType: .audio).first {
                if audioTrack == nil {
                    audioTrack = composition.addMutableTrack(withMediaType: .audio,
                                                             preferredTrackID: kCMPersistentTrackID_Invalid)
                }
                try? audioTrack?.insertTimeRange(range, of: a, at: cursor)
            }
            cursor = CMTimeAdd(cursor, duration)
        }

        guard cursor.seconds > 0,
              let export = AVAssetExportSession(asset: composition,
                                                presetName: AVAssetExportPresetHighestQuality) else { return nil }
        let outURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        export.outputURL = outURL
        export.outputFileType = .mov

        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            export.exportAsynchronously { c.resume() }
        }
        return export.status == .completed ? outURL : nil
    }
}

// MARK: - Recording delegate
extension CameraManager: AVCaptureFileOutputRecordingDelegate {

    func fileOutput(_ output: AVCaptureFileOutput,
                    didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            if self.nextIsNewTake { self.currentTake += 1 }
            self.activeTake = self.currentTake
            self.isRecording = true
            self.startTimer()
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        DispatchQueue.main.async {
            self.isRecording = false
            self.stopTimer()
            self.setTorch(false)
            let duration = self.recordingElapsed
            if error == nil, duration >= 0.3 {
                self.segments.append(outputFileURL)
                self.segmentDurations.append(duration)
                self.segmentTakes.append(self.activeTake)
                self.totalRecordedDuration += duration
                self.lastRecordingURL = outputFileURL
            }
            self.recordingElapsed = 0

            if self.resumeAfterFlip {
                self.resumeAfterFlip = false
                self.sessionQueue.async {
                    self.swapCameraInput()
                    DispatchQueue.main.async {
                        self.nextIsNewTake = false
                        self.beginCapture()
                    }
                }
            }
        }
    }
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    init(completion: @escaping (UIImage?) -> Void) { self.completion = completion }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil, let data = photo.fileDataRepresentation() else {
            completion(nil); return
        }
        completion(UIImage(data: data))
    }
}
