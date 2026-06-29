//
//  Network.swift
//  Binbon
//
//  Created by Salah Khaled on 28/02/2026.
//

import UIKit
import SystemConfiguration
import Combine


// MARK: - Network
final class Network {
    
    // MARK: - Properties
    static let shared = Network()
    private(set) var session: URLSession
    private let requestTime: TimeInterval = 60
    private let decoder = JSONDecoder()
    /// Tracks one in-flight URLSession task per URL so concurrent callers for the
    /// same URL coalesce into a single network request rather than each firing their own.
    var inflightImages: [URL: Task<UIImage?, Never>] = [:]
    @Published var imageCache = [URL: UIImage]()
    let unauthorize = PassthroughSubject<Void, Never>()
    
    // MARK: - Init
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Call
    func call<T: Decodable>(_ service: ServiceProtocol) async throws -> T {
        
        guard let request = URLRequest(service: service, cachePolicy: cachePolicy(service.method == .GET), timeoutInterval: requestTime)
        else { throw APIError(type: .url) }
        
        let startTime = Date()
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw APIError(type: .request) }
            
            let result: T = try mapResponse(service: service, response: httpResponse, with: data)
            let elapsed = Date().timeIntervalSince(startTime)
            Console.log(service: service, request: request, data: data, code: httpResponse.statusCode, elapsed: elapsed, expected: "\(T.self)")
            return result
        } catch {
            let apiError = mapError(error)
            
            let elapsed = Date().timeIntervalSince(startTime)
            Console.log(service: service, request: request, data: nil, code: apiError.code, elapsed: elapsed, error: apiError, expected: "\(T.self)")
            throw apiError
        }
    }
    
    
    // MARK: - Response
    private func mapResponse<T: Decodable>(service: ServiceProtocol, response: HTTPURLResponse, with data: Data?) throws -> T {
        
        guard let apiData = data else { throw APIError(type: .request, code: response.statusCode) }
        
        let statusCode = response.statusCode
        switch statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: apiData)
            } catch let decodeError as DecodingError {
                throw APIError(type: .parsing, code: statusCode, message: decodeError.errorPath)
            } catch {
                throw APIError(type: .parsing, code: statusCode)
            }
            
        case 400...499:
            if statusCode == 401 { unauthorize.send() }
            
            let message = try? decoder.decode(FailResponse.self, from: apiData).message
            throw APIError(type: statusCode == 401 ? .unauthorized : .request, code: statusCode, message: message)
            
        default:
            guard let fail = try? decoder.decode(FailResponse.self, from: apiData) else {
                throw APIError(type: .server, code: statusCode)
            }
            throw APIError(type: .backend, code: statusCode, message: fail.message)
        }
    }
    
    // MARK: - Error
    func mapError(_ error: Error) -> APIError {
        switch error {
        case let apiError as APIError: apiError
        case let urlError as URLError: .init(type: .network, message: urlError.localizedDescription.capitalFirst)
        default: .init(type: .unknown, message: error.localizedDescription.capitalFirst)
        }
    }
}

// MARK: - Extensions
private extension Network {
    private func cachePolicy(_ isCache: Bool) -> URLRequest.CachePolicy {
        return isCache
        ? (Connectivity.shared.isOnline ? .reloadIgnoringCacheData : .returnCacheDataDontLoad)
        : .reloadIgnoringCacheData
    }
    

}
