//
//  AuthService.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging


let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")


struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    
    static var CURRENT_USER: User? {
        if let currentUser = Auth.auth().currentUser {
            return currentUser
        }
        return nil
    }
    static var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return REF_USERS.child(currentUser.uid)
    }
    
    static func logUserIn(withEmail email: String, andPassword password: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessag: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, loginError) in
            if loginError != nil {
                print("JOSH: Error Logging User into Firebase with error \(loginError?.localizedDescription)")
                onError(loginError?.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    static func signUserUp(withCredentials credentials: AuthCredentials, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String?) -> Void) {
        Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (authResult, signupError) in
            if signupError != nil {
                print("JOSH: Error Creating Firebase User \(signupError?.localizedDescription)")
                onError(signupError?.localizedDescription)
                return
            }
            guard let fcmToken = Messaging.messaging().fcmToken else { return }
            let image = credentials.profileImage
            StorageService.uploadUserProfileImage(image: image) { (profileImageUrlString) in
                let userDict: [String: Any] = [USER_EMAIL: credentials.email,
                                               USER_FULLNAME: credentials.fullname,
                                               USER_USERNAME: credentials.username.lowercased(),
                                               USER_PROFILE_IMAGE_URL: profileImageUrlString,
                                               USER_FCM_TOKEN: fcmToken]
                REF_CURRENT_USER?.updateChildValues(userDict)
                onSuccess()
            }
        }
    }
    static func checkIfUserIsLoggedIn(completion: @escaping(Bool) -> Void) {
        if CURRENT_USER == nil {
            completion(false)
        } else {
            completion(true)
        }
    }
    static func logUserOut(onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String?) -> Void) {
        do {
            try Auth.auth().signOut()
            onSuccess()
        } catch (let logoutError) {
            print("JOSH: Error Logging User Out \(logoutError.localizedDescription)")
            onError(logoutError.localizedDescription)
        }
    }
    static func sendPasswordReset(withEmail email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (resetError) in
            if resetError != nil {
                onError(resetError?.localizedDescription)
            }
            onSuccess()
        }
    }
}
