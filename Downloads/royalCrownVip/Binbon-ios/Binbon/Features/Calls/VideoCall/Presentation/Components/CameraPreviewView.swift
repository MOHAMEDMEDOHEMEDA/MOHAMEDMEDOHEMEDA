//  CameraPreviewView.swift
//  Binbon

import AVFoundation
import SwiftUI

/// Wraps AVCaptureVideoPreviewLayer so the live camera feed can be used inside SwiftUI.
struct CameraPreviewView: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> _PreviewView {
        let view = _PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: _PreviewView, context: Context) {}

    /// Drop the session reference when the tile is removed so the preview layer
    /// doesn't keep the old AVCaptureSession (and the camera) alive into the next call.
    static func dismantleUIView(_ uiView: _PreviewView, coordinator: ()) {
        uiView.previewLayer.session = nil
    }

    class _PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
