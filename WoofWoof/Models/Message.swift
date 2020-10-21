//
//  Message.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import Firebase

struct Message {
    let text: String
    let toId: String
    let fromId: String
    var timestamp: Date!
    var user: UserModel?
    var imageUrl: String?
    var imageWidth: CGFloat?
    var imageHeight: CGFloat?
    var imageRatio: CGFloat?
    var videoUrl: String?
    var read: Bool!

    var isFromCurrentUser: Bool

    var chatPartnerId: String {
        return isFromCurrentUser ? toId : fromId
    }

    init(messageDict: [String: Any]) {
        self.text = messageDict[MESSAGE_TEXT] as? String ?? ""
        self.toId = messageDict[MESSAGE_TO_ID] as? String ?? ""
        self.fromId = messageDict[MESSAGE_FROM_ID] as? String ?? ""
        
        // Use if let to avoid creating empty properties in Firebase
        if let imageUrl = messageDict[MEDIA_IMAGE_URL] as? String {
            self.imageUrl = imageUrl
        }
        if let videoUrl = messageDict[MEDIA_VIDEO_URL] as? String {
            self.videoUrl = videoUrl
        }
        if let imageWidth = messageDict[MEDIA_IMAGE_WIDTH] as? CGFloat {
            self.imageWidth = imageWidth
        }
        if let imageHeight = messageDict[MEDIA_IMAGE_HEIGHT] as? CGFloat {
            self.imageHeight = imageHeight
        }
        if let imageRatio = messageDict[MEDIA_IMAGE_RATIO] as? CGFloat {
            self.imageRatio = imageRatio
        }
        if let read = messageDict[MESSAGE_READ] as? Bool {
            self.read = read
        }
        if let timestamp = messageDict[POST_TIMESTAMP] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        self.isFromCurrentUser = fromId == AuthService.CURRENT_USER?.uid
    }
}

struct Conversation {
    let user: UserModel
    let message: Message
}
