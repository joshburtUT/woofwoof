//
//  Validator.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import Foundation

class ValidationError: Error {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
}

protocol ValidatorConvertible {
    func validated(_ value: String) throws -> String
}

enum ValidatorType {
    case email, password, username, fullname
}

enum ValidatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .email:
            return EmailValidator()
        case .password:
            return PasswordValidator()
        case .username:
            return UsernameValidator()
        case .fullname:
            return FullnameValidator()
        }
    }
}

struct EmailValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        do {
            if try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid email address")
            }
        } catch {
            throw ValidationError("Invalid email address")
        }
        return value
    }
}

struct PasswordValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else { throw ValidationError("Password must have at least 6 characters, with at least one alpha character and one numeric character and no special characters.") }
        guard value.count >= 6 else { throw ValidationError("Password must have at least 6 characters, with at least one alpha character and one numeric character and no special characters.") }
        
        do {
            if try NSRegularExpression(pattern: "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Password must have at least 6 characters, with at least one alpha character and one numeric character and no special characters.")
            }
        } catch {
            throw ValidationError("Password must have at least 6 characters, with at least one alpha character and one numeric character and no special characters.")
        }
        return value
    }
}

struct UsernameValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value.count >= 4 else { throw ValidationError("Username must contain more than 3 characters.") }
        guard value.count <= 18 else { throw ValidationError("Username shouldn't contain more than 18 characters.") }
        
        do {
            if try NSRegularExpression(pattern: "^[a-z]{3,18}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
            throw ValidationError("Invalid username, username should not contain whitespaces, numbers or special characters")
            }
        } catch {
            throw ValidationError("Invalid username, username should not contain whitespaces, numbers or special characters")
        }
        return value
    }
}

struct FullnameValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value.count >= 3 else { throw ValidationError("Full Name must contain more than 3 characters.") }
        guard value.count < 30 else { throw ValidationError("Full Name is limited to 30 characters.") }
        
        do {
            // TODO: Add Space, hyphen, apostrophe
            if try NSRegularExpression(pattern: "^[A-Za-z ]{3,30}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
            throw ValidationError("Please check your entry.")
            }
        } catch {
            throw ValidationError("Please check your entry.")
        }
        return value
    }
}
