//
//  ProfileHeaderViewModel.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    case posts
    case replies
    case likes

    var description: String {
        switch self {
        case .posts: return "Posts"
        case .replies: return "Posts & Replies"
        case .likes: return "Likes"
        }
    }
}

struct ProfileHeaderViewModel {
    
    // MARK: - Properties
    private let user: UserModel
    
    let usernameText: String
    
    var followersString: NSAttributedString? {
        return attributedText(withValue: user.stats?.followers ?? 0, text: "followers")
    }
    var followingString: NSAttributedString? {
        return attributedText(withValue: user.stats?.following ?? 0, text: "following")
    }
    var actionButtonTitle: String {
        if user.isCurrentUser {
            return "Settings"
        }
        if !user.isFollowed && !user.isCurrentUser {
            return "Follow"
        }
        if user.isFollowed {
            return "Following"
        }
        return "Loading.."
    }
    
    // MARK: - Lifecycle
    init(user: UserModel) {
        self.user = user
        self.usernameText = "@" + user.username
    }

    
    // MARK: - Helpers
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font : UIFont.boldSystemFont(ofSize: 16),
                                                                                         .foregroundColor: UIColor.myTitleLabelColor])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font : UIFont.systemFont(ofSize: 14),
                                                                                   .foregroundColor : UIColor.lightGray]))
        return attributedTitle
    }
}

