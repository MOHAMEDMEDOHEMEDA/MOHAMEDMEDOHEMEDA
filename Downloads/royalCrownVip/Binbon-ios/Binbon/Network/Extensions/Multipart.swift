//
//  Multipart.swift
//  Binbon
//
//  Created by Salah Khaled on 20/04/2026.
//

import UIKit

struct Multipart {

    let boundary = "Boundary-\(UUID().uuidString)"

    private var body = Data()

    // MARK: - Text Field
    mutating func field(_ name: String, value: String?) {
        guard let value else { return }
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }

    // MARK: - Image Field
    mutating func image(_ name: String, image: UIImage?, filename: String = "image.jpeg") {
        guard let image, let data = image.jpegData(compressionQuality: 0.8) else { return }
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(data)
        body.append("\r\n")
    }

    // MARK: - Build
    func build() -> Data {
        var result = body
        result.append("--\(boundary)--\r\n")
        return result
    }
}

// MARK: - Data Helper
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
