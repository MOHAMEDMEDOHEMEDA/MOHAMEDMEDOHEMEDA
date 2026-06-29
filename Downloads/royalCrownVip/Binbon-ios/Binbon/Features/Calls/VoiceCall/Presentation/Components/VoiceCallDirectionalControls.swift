//
//  VoiceCallDirectionalControls.swift
//  Binbon
//
//  UIKit-backed call controls that keep Figma icon orientation in Arabic.
//

import SwiftUI
import UIKit

// MARK: - System icon

struct VoiceCallSystemIcon: UIViewRepresentable {
    let systemName: String
    let pointSize: CGFloat
    let color: UIColor

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.semanticContentAttribute = .forceLeftToRight
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        imageView.semanticContentAttribute = .forceLeftToRight
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
        guard let symbol = UIImage(systemName: systemName, withConfiguration: config) else { return }

        let canvas = CGSize(width: pointSize * 1.6, height: pointSize * 1.6)
        let format = UIGraphicsImageRendererFormat()
        format.scale = imageView.traitCollection.displayScale
        format.opaque = false

        let tinted = symbol.withTintColor(color, renderingMode: UIImage.RenderingMode.alwaysOriginal)
        let raster = UIGraphicsImageRenderer(size: canvas, format: format).image { _ in
            tinted.draw(in: CGRect(origin: .zero, size: canvas))
        }

        imageView.image = raster
        imageView.tintColor = nil
    }
}

// MARK: - Asset icon

struct VoiceCallAssetIcon: UIViewRepresentable {
    let name: String
    let usesTemplate: Bool
    let tintColor: UIColor?

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.semanticContentAttribute = .forceLeftToRight
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        imageView.semanticContentAttribute = .forceLeftToRight
        guard let image = UIImage(named: name) else { return }
        if usesTemplate, let tintColor {
            imageView.image = image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imageView.tintColor = tintColor
        } else {
            imageView.image = image.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            imageView.tintColor = nil
        }
    }
}

// MARK: - LTR switch

struct VoiceCallLTRSwitch: UIViewRepresentable {
    @Binding var isOn: Bool
    let onTintColor: UIColor
    let size: CGSize

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UISwitch {
        let toggle = UISwitch()
        toggle.semanticContentAttribute = .forceLeftToRight
        toggle.onTintColor = onTintColor
        toggle.isOn = isOn
        toggle.transform = CGAffineTransform(
            scaleX: size.width / 51,
            y: size.height / 31
        )
        toggle.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        return toggle
    }

    func updateUIView(_ toggle: UISwitch, context: Context) {
        if toggle.isOn != isOn {
            toggle.setOn(isOn, animated: true)
        }
        toggle.onTintColor = onTintColor
    }

    final class Coordinator: NSObject {
        var parent: VoiceCallLTRSwitch

        init(_ parent: VoiceCallLTRSwitch) {
            self.parent = parent
        }

        @objc func valueChanged(_ sender: UISwitch) {
            parent.isOn = sender.isOn
        }
    }
}

// MARK: - SwiftUI wrapper

extension View {
    /// Pins control glyphs to LTR so directional SF Symbols never mirror in Arabic.
    func voiceCallDirectionFixed() -> some View {
        environment(\.layoutDirection, .leftToRight)
    }
}
