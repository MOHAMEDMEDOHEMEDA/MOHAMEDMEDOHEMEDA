//
//  Key.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import Foundation
import SwiftUI

// MARK: - Keys
extension Storage {
    enum Key: String {
        case version
        case token
        case user
        case language
        case didLaunch
        case theme
    }
}

// MARK: - Storage
final class Storage {
    
    static let shared = Storage()
    private init() { syncVersion() }
    
    func clear(_ key: Key) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
    func logout() {
        clear(.user)
        clear(.token)
    }
    
    // MARK: - Defaults
    @UserDefault(key: Key.version, default: nil)
    var version: String?
    
    @UserDefault(key: Key.token, default: nil)
    var token: String?
    
    @UserDefault(key: Key.user, default: nil)
    var user: UserResponse?
    
    @UserDefault(key: Key.language, default: Language.english.rawValue)
    var language: String

    @UserDefault(key: Key.didLaunch, default: false)
    var didLaunch: Bool

    @UserDefault(key: Key.theme, default: AppThemeMode.colored.rawValue)
    var theme: String
}

// MARK: - Environment
private struct StorageKey: EnvironmentKey {
    static let defaultValue: Storage = .shared
}

extension EnvironmentValues {
    var storage: Storage {
        get { self[StorageKey.self] }
        set { self[StorageKey.self] = newValue }
    }
}

// MARK: - Wrapper
@propertyWrapper
struct UserDefault<T: Codable> {
    let key: Storage.Key
    let `default`: T
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key.rawValue),
                  let decoded = try? JSONDecoder().decode(T.self, from: data) else {
                
                return `default`
            }
            return decoded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else {
                print("📂 [Storage] Can't set a value (\(newValue)) - for key (\(key.rawValue))")
                return
            }
            UserDefaults.standard.set(encoded, forKey: key.rawValue)
        }
    }
}

// MARK: - Version
extension Storage {
    func syncVersion() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        self.version = "\(version ?? "") (\(build ?? ""))"
    }
}
