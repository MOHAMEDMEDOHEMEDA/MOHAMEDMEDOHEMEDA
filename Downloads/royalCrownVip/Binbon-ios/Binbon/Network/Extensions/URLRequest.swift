//
//  URLRequest.swift
//  Binbon
//
//  Created by Salah Khaled on 28/02/2026.
//

import UIKit

// MARK: - URLRequest
extension URLRequest {
    
    fileprivate enum Value {
        static let appJson = "application/json"
        static let iOS = "iOS"
        static let locale = "en"
        static let retry123 = "retry123"
    }
    
    init?(service: ServiceProtocol, cachePolicy: CachePolicy, timeoutInterval: TimeInterval) {
        guard let components = URLComponents(service: service),
              let url = components.url else { return nil }
        
        self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        httpMethod = service.method.rawValue
        
        addValue(Value.appJson, forHTTPHeaderField: APIHeader.contentType)
        addValue(Value.appJson, forHTTPHeaderField: APIHeader.accept)
        addValue(Value.iOS, forHTTPHeaderField: APIHeader.platform)
        addValue(Value.locale, forHTTPHeaderField: APIHeader.locale)
        addValue(Value.retry123, forHTTPHeaderField: APIHeader.apiKey)
        
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            addValue(uuid, forHTTPHeaderField: APIHeader.deviceId)
        }
        
        if let version = Storage.shared.version {
            addValue(version, forHTTPHeaderField: APIHeader.version)
        }
        
        if let token = Storage.shared.token {
            addValue(token, forHTTPHeaderField: APIHeader.token)
        }
        
        /// Set Headers
        service.headers?.forEach {
            addValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        /// Body Encoding
        if let multiBody = (service as? any MultipartProtocol)?.multiBody {
            httpBody = multiBody.data
            setValue("multipart/form-data; boundary=\(multiBody.boundary)", forHTTPHeaderField: APIHeader.contentType)
        } else if let body = service.body {
            httpBody = try? JSONEncoder().encode(body)
        }
    }
}


// MARK: - URLComponents
extension URLComponents {
    
    init?(service: ServiceProtocol) {
        guard let baseURL = URL(string: service.url) else { return nil }
        
        let url = baseURL.appendingPathComponent(service.path)
        self.init(url: url, resolvingAgainstBaseURL: false)
        
        if let parameters = service.parameters {
            queryItems = parameters
                .sorted { $0.key < $1.key }
                .map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
    }
}
