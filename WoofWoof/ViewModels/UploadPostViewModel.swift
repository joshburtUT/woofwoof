//
//  UploadPostViewModel.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

enum UploadPostConfiguration {
    case post
    case reply(Post)
}

struct UploadViewModel {
    
    let actionButtonTitle: String
    let placeholderText: String
    var shouldShowReplyLabel: Bool
    var replyText: String?
    
    init(config: UploadPostConfiguration) {
        switch config {
        case .post:
            actionButtonTitle = "Post"
            placeholderText = "What's happening?"
            shouldShowReplyLabel = false
        case .reply(let post):
            actionButtonTitle = "Reply"
            placeholderText = "Post your reply..."
            shouldShowReplyLabel = true
            replyText = "Replying to @\(post.user.username)"
            
        }
    }
}
