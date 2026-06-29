//
//  StoryEditorLayout.swift
//  Binbon
//

import SwiftUI

enum StoryEditorLayout {

    static func cardSize(in container: CGSize) -> CGSize {
        let maxWidth = container.width - 48
        let maxHeight = container.height * 0.72
        let aspect: CGFloat = 9 / 16

        var width = maxWidth
        var height = width / aspect
        if height > maxHeight {
            height = maxHeight
            width = height * aspect
        }
        return CGSize(width: width, height: height)
    }
}
