//
//  Notification.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import Foundation

enum NotificationType: Int {
    case follow
    case like
    case reply
    case retweet
    case mention
//    case report
    
    var description: String {
        switch self {
        case .follow: return " started following you"
        case .like: return " liked your post"
        case .reply: return " replied to your post"
        case .retweet: return " retweeted your post"
        case .mention: return " mentioned you in a post"
        }
    }
}

struct Notification {
    var notificationId: String!
    var postId: String?
    var timestamp: Date!
    var user: UserModel
    var post: Post?
    var type: NotificationType!
    
    init(user: UserModel, notificationDict: [String: Any]) {
        self.user = user
        
        if let postId = notificationDict[NOTIFICATION_POST_ID] as? String {
            self.postId = postId
        }
        if let timestamp = notificationDict[NOTIFICATION_TIMESTAMP] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        if let type = notificationDict[NOTIFICATION_TYPE] as? Int {
            self.type = NotificationType(rawValue: type)
        }
        if let notificationId = notificationDict[NOTIFICATION_ID] as? String {
            self.notificationId = notificationId
        }
    }
}
