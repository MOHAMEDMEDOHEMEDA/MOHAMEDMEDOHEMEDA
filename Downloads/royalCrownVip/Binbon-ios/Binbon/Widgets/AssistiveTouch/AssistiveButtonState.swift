//
//  AssistiveButtonState.swift
//  Binbon
//
//  Shared state for the floating AssistiveTouch-style button: its last dragged
//  position and the temporary-hide timer triggered by a long press.
//

import SwiftUI
import Combine

@MainActor
final class AssistiveButtonState: ObservableObject {

    static let shared = AssistiveButtonState()

    /// Last position the user dragged the button to. `nil` until first placed,
    /// so the overlay can fall back to its default right-edge spot.
    @Published var position: CGPoint?

    /// Hidden after a long press; flips back automatically once the timer fires.
    @Published var isHidden = false

    /// How long the button stays hidden after a long press.
    private let hideDuration: TimeInterval = 300 // 5 minutes

    private var unhideTask: Task<Void, Never>?

    private init() {}

    func hideTemporarily() {
        isHidden = true
        unhideTask?.cancel()
        unhideTask = Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(self.hideDuration))
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                self.isHidden = false
            }
        }
    }
}
