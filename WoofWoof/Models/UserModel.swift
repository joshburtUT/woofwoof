//
//  UserModel.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import Foundation

struct UserModel {
    var fullname: String
    let email: String
    var username: String
    var profileImageUrl: URL?
    let uid: String
    var isFollowed = false
    var stats: UserRelationStats?
    var bio: String?
    var fcmToken: String?
    
    var isCurrentUser: Bool {
        return AuthService.CURRENT_USER?.uid == uid
    }
    
    init(uid: String, userDict: [String: Any]) {
        self.uid = uid
        
        self.fullname = userDict[USER_FULLNAME] as? String ?? ""
        self.email = userDict[USER_EMAIL] as? String ?? ""
        self.username = userDict[USER_USERNAME] as? String ?? ""
        
        if let profileImageUrlString = userDict[USER_PROFILE_IMAGE_URL] as? String {
            guard let url = URL(string: profileImageUrlString) else { return }
            self.profileImageUrl = url
        }
        if let bio = userDict[USER_BIO] as? String {
            self.bio = bio
        }
        if let fcmToken = userDict[USER_FCM_TOKEN] as? String {
            self.fcmToken = fcmToken
        }
    }
}

struct UserRelationStats {
    var followers: Int
    var following: Int
}

