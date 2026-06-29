//
//  BiometricAuthManager.swift
//  Binbon
//
//  Created by Ali Mohamed on 04/06/2026.
//

import LocalAuthentication


struct BiometricAuthManager {

    // MARK: - Biometry
    enum Biometry {
        case none
        case touchID
        case faceID
        case opticID

        var iconName: String {
            switch self {
            case .none: "lock.slash"
            case .touchID: "touchid"
            case .faceID: "faceid"
            case .opticID: "opticid"
            }
        }

        var titleKey: String {
            switch self {
            case .none: "biometric_management"
            case .touchID: "touch_id"
            case .faceID: "face_id"
            case .opticID: "optic_id"
            }
        }

        var apiValue: String {
            switch self {
            case .none: "none"
            case .touchID: "fingerprint"
            case .faceID: "face"
            case .opticID: "optic"
            }
        }
    }

    // MARK: - Error
    enum BiometricError: Error {
        case notAvailable
        case notEnrolled
        case lockout
        case passcodeNotSet
        case cancelled
        case failed

        var messageKey: String {
            switch self {
            case .notAvailable: "biometric_error_not_available"
            case .notEnrolled: "biometric_error_not_enrolled"
            case .lockout: "biometric_error_lockout"
            case .passcodeNotSet: "biometric_error_passcode_not_set"
            case .cancelled: "biometric_error_failed"
            case .failed: "biometric_error_failed"
            }
        }

        var isSilent: Bool { self == .cancelled }
    }

    // MARK: - Capability
    var biometry: Biometry {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        case .opticID: return .opticID
        default: return .none
        }
    }

    var hasHardware: Bool { biometry != .none }
    var canEvaluate: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    // MARK: - Authenticate
    func authenticate(reason: String) async -> Result<Void, BiometricError> {
        let context = LAContext()

        var probeError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &probeError) else {
            return .failure(mapError(probeError))
        }

        do {
            try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return .success(())
        } catch {
            return .failure(mapError(error as NSError))
        }
    }

    // MARK: - Error Mapping
    private func mapError(_ error: NSError?) -> BiometricError {
        guard let error, let code = LAError.Code(rawValue: error.code) else { return .failed }
        switch code {
        case .biometryNotAvailable: return .notAvailable
        case .biometryNotEnrolled: return .notEnrolled
        case .biometryLockout: return .lockout
        case .passcodeNotSet: return .passcodeNotSet
        case .userCancel, .appCancel, .systemCancel: return .cancelled
        default: return .failed
        }
    }
}
