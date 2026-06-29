//
//  API.swift
//  Binbon
//
//  Created by Salah Khaled on 28/02/2026.
//

import Foundation

/**
 APIConfiguration

 - parameter development: For the application during the development phase.
 - parameter production: For the application during the launching on App store.
 */

let API = Api(config: .development)

enum APIConfiguration {
    case development
    case production
}

final class Api {

    let config: APIConfiguration

    init(config: APIConfiguration) {
        self.config = config
    }

    // MARK: - Base Url
    var baseUrl: String {
        switch config {
        case .development: ""
        case .production: ""
        }
    }
    
    // Endpoint paths were removed for the UI-only / pre-API phase. The networking
    // core (`Network`, `ServiceProtocol`) is kept for later API integration —
    // add the endpoint constants back here when wiring real services.
}
