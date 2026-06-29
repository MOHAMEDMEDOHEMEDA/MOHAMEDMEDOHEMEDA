//
//  ShareProfileViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 01/05/2026.
//

import UIKit
import Combine

@MainActor
final class ShareProfileViewModel: ObservableObject {

    // MARK: - Properties
    @Published var error: APIError?
    @Published var isLoading: Bool = false
    @Published var shareResponse: ShareLinkResponse?

    private let shareLinkUseCase: ShareLinkUseCase

    init(shareLinkUseCase: ShareLinkUseCase) {
        self.shareLinkUseCase = shareLinkUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(shareLinkUseCase: container.makeShareLinkUseCase())
    }

    // MARK: - Methods
    func shareProfile() {
        guard let shareUrl = shareResponse?.shareUrl, let url = URL(string: shareUrl) else { return }

        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    func copyURL() {
        guard let shareUrl = shareResponse?.shareUrl else { return }

        UIPasteboard.general.string = shareUrl
        Toaster.shared.show(.success("square.on.square"), "URL copied to clipboard")
    }

    func fetchShareDetail() {
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            do { self.shareResponse = try await shareLinkUseCase.execute() }
            catch { self.error = Network.shared.mapError(error) }
        }
    }
}
