//
//  UIImage+Normalized.swift
//  Binbon
//

import UIKit

extension UIImage {
    /// Returns an upright copy so gallery picks display without rotation or odd cropping.
    func normalizedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
