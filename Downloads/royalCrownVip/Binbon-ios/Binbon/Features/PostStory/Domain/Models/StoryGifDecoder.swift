//
//  StoryGifDecoder.swift
//  Binbon
//

import ImageIO
import UIKit

enum StoryGifDecoder {

    static func data(from reference: String) -> Data? {
        guard let url = StoryGifURLResolver.url(from: reference) else { return nil }
        return try? Data(contentsOf: url)
    }

    static func decode(reference: String) -> (images: [UIImage], duration: TimeInterval)? {
        guard let data = data(from: reference) else { return nil }
        return decode(data: data)
    }

    static func decode(data: Data) -> (images: [UIImage], duration: TimeInterval)? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var duration: TimeInterval = 0

        for index in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            images.append(UIImage(cgImage: cgImage))
            duration += frameDelay(source: source, index: index)
        }

        guard !images.isEmpty else { return nil }
        return (images, max(duration, 0.1))
    }

    static func firstFrame(reference: String) -> UIImage? {
        decode(reference: reference)?.images.first
    }

    private static func frameDelay(source: CGImageSource, index: Int) -> TimeInterval {
        guard
            let props = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
            let gif = props[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        else {
            return 0.1
        }

        let unclamped = gif[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval
        let clamped = gif[kCGImagePropertyGIFDelayTime] as? TimeInterval
        return unclamped ?? clamped ?? 0.1
    }
}
