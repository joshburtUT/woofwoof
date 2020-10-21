//
//  Post.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import Foundation


struct Post {
    let caption: String
    let postId: String
    let postOwner: String
    var likes: Int
    var retweets: Int
    var timestamp: Date!
    var user: UserModel
    var didLike = false
    var didRetweet = false
    
    var replyingTo: String?
    
    var isReply: Bool {
        return replyingTo != nil
    }
    
    init(user: UserModel, postId: String, postDict: [String: Any]) {
        self.user = user
        self.postId = postId
        
        self.caption = postDict[POST_CAPTION] as? String ?? ""
        self.postOwner = postDict[POST_OWNER] as? String ?? ""
        self.likes = postDict[POST_LIKES] as? Int ?? 0
        self.retweets = postDict[POST_RETWEETS] as? Int ?? 0

        if let timestamp = postDict[POST_TIMESTAMP] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        if let replyingTo = postDict[POST_REPLYING_TO] as? String {
            self.replyingTo = replyingTo
        }
    }
}

struct PostRelationStats {
    var likes: Int
    var replies: Int
    var retweets: Int
}
