//
//  VideoEffects.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

// MARK: - Color filter
enum VideoFilter: String, CaseIterable, Identifiable {
    case none, mono, noir, fade, warm, cool, vivid, chrome, instant

    var id: String { rawValue }

    var titleKey: String { "vf_\(rawValue)" }

    var overlay: (color: Color, blend: BlendMode, opacity: Double)? {
        switch self {
        case .none:    return nil
        case .mono:    return (.gray, .saturation, 1.0)
        case .noir:    return (.black, .saturation, 1.0)
        case .fade:    return (.white, .overlay, 0.18)
        case .warm:    return (Color(hex: "FF8A3D"), .softLight, 0.35)
        case .cool:    return (Color(hex: "3D9BFF"), .softLight, 0.35)
        case .vivid:   return (Color(hex: "FF4D6D"), .softLight, 0.22)
        case .chrome:  return (Color(hex: "7FE3FF"), .softLight, 0.30)
        case .instant: return (Color(hex: "C2A06B"), .softLight, 0.40)
        }
    }

    func apply(to input: CIImage) -> CIImage {
        switch self {
        case .none:
            return input
        case .mono:    return photoEffect("CIPhotoEffectMono", input)
        case .noir:    return photoEffect("CIPhotoEffectNoir", input)
        case .fade:    return photoEffect("CIPhotoEffectFade", input)
        case .chrome:  return photoEffect("CIPhotoEffectChrome", input)
        case .instant: return photoEffect("CIPhotoEffectInstant", input)
        case .warm:    return temperature(input, neutral: 4800)
        case .cool:    return temperature(input, neutral: 9200)
        case .vivid:
            let f = CIFilter.colorControls()
            f.inputImage = input
            f.saturation = 1.45
            f.contrast = 1.05
            return f.outputImage ?? input
        }
    }

    private func photoEffect(_ name: String, _ input: CIImage) -> CIImage {
        guard let f = CIFilter(name: name) else { return input }
        f.setValue(input, forKey: kCIInputImageKey)
        return f.outputImage ?? input
    }

    private func temperature(_ input: CIImage, neutral: CGFloat) -> CIImage {
        let f = CIFilter.temperatureAndTint()
        f.inputImage = input
        f.neutral = CIVector(x: 6500, y: 0)
        f.targetNeutral = CIVector(x: neutral, y: 0)
        return f.outputImage ?? input
    }
}

// MARK: - Visual effect
enum VideoEffect: String, CaseIterable, Identifiable {
    case none, vignette, glow, comic, posterize, pixellate

    var id: String { rawValue }
    var titleKey: String { "ve_\(rawValue)" }

    var icon: String {
        switch self {
        case .none:      return "circle.slash"
        case .vignette:  return "circle.lefthalf.filled"
        case .glow:      return "sparkles"
        case .comic:     return "scribble.variable"
        case .posterize: return "square.stack.3d.down.right"
        case .pixellate: return "squareshape.split.3x3"
        }
    }

    func apply(to input: CIImage) -> CIImage {
        switch self {
        case .none:
            return input
        case .vignette:
            let f = CIFilter.vignette()
            f.inputImage = input
            f.intensity = 1.6
            f.radius = 2.2
            return f.outputImage ?? input
        case .glow:
            let f = CIFilter.bloom()
            f.inputImage = input
            f.radius = 8
            f.intensity = 1.0
            return (f.outputImage ?? input).cropped(to: input.extent)
        case .comic:
            let f = CIFilter.comicEffect()
            f.inputImage = input
            return f.outputImage ?? input
        case .posterize:
            let f = CIFilter.colorPosterize()
            f.inputImage = input
            f.levels = 6
            return f.outputImage ?? input
        case .pixellate:
            let f = CIFilter.pixellate()
            f.inputImage = input
            f.scale = 8
            return (f.outputImage ?? input).cropped(to: input.extent)
        }
    }
}

// MARK: - Record speed
enum VideoSpeed: Double, CaseIterable, Identifiable {
    case veryslow = 0.3
    case slow     = 0.5
    case normal   = 1.0
    case fast     = 2.0
    case veryfast = 3.0

    var id: Double { rawValue }

    var label: String {
        switch self {
        case .normal: return "1x"
        default:
            let v = rawValue
            return (v == v.rounded() ? String(format: "%.0fx", v) : String(format: "%.1fx", v))
        }
    }
}

// MARK: - Active bottom panel
enum VideoEffectPanel {
    case none, filters, effects, speed
}

// MARK: - Effect state
final class VideoEffectsState: ObservableObject {
    @Published var filter: VideoFilter
    @Published var effect: VideoEffect = .none
    @Published var speed: VideoSpeed = .normal
    @Published var beauty = false
    @Published var countdown = 0
    @Published var panel: VideoEffectPanel = .none
    @Published var railExpanded = false

    init(filter: VideoFilter = .none) {
        self.filter = filter
    }

    var needsExport: Bool {
        filter != .none || effect != .none || beauty || speed != .normal
    }

    func cycleCountdown() {
        switch countdown {
        case 0:  countdown = 3
        case 3:  countdown = 10
        default: countdown = 0
        }
    }

    func togglePanel(_ target: VideoEffectPanel) {
        panel = (panel == target) ? .none : target
    }
}
