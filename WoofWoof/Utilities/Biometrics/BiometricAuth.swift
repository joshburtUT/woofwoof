//
//  BiometricAuth.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
}

struct KeychainConfig {
    static let serviceName = "WooferApp"
    static let accessGroup: String? = nil
}

struct KeychainConstants {
    static let kEmail = "email"
    static let kBiometricEnabled = "biometricEnabled"
}


class BiometricAuth {
    
    let context = LAContext()
    var reason = "Logging in with Touch ID"
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .none: return .none
        case .touchID: return .touchID
        case .faceID: return .faceID
        }
    }
    
    func authenticateUser(completion: @escaping(String?) -> Void) {
        guard canEvaluatePolicy() else {
            completion("Biometric Authenication is not available.")
            return
        }
    
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, evaluationError) in
            // Run on main thread, regardless of success or failure to ensure the user interface code is exposed for use...crashes otherwise when cancel is tapped.
            DispatchQueue.main.async {
                if success {
                    completion(nil)
                } else {
                    let message: String
                    
                    switch evaluationError {
                        
                    case LAError.authenticationFailed?:
                        message = "There was a problem verifying your identity; please try again."
                    case LAError.userCancel?:
                        message = "You pressed cancel."
                    case LAError.userFallback?:
                        message = "You pressed password."
                    case LAError.biometryNotAvailable?:
                        message = "Face ID/Touch ID is not available."
                    case LAError.biometryNotEnrolled?:
                        message = "Face ID/Touch ID is not set up."
                    case LAError.biometryLockout?:
                        message = "Face ID/Touch ID is locked."
                    default:
                        message = "Face ID/Touch ID may not be configured."
                    }
                    completion(message)
                }
            }
        }
    }
}
