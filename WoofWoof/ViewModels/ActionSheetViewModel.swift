//
//  ActionSheetViewModel.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import Foundation

enum ActionSheetOptions {
    case follow(UserModel)
    case unfollow(UserModel)
    case report
    case delete
    
    var description: String {
        switch self {
        case .follow(let user):
            return "Follow @\(user.username)"
        case .unfollow(let user):
            return "Unfollow @\(user.username)"
        case .report:
            return "Report Post"
        case .delete:
            return "Delete Post"
        }
    }
}

struct ActionSheetViewModel {
    
    // MARK: - Properties
    private let user: UserModel
    var options: [ActionSheetOptions] {
        // create an array to hold the action sheet options
        var results = [ActionSheetOptions]()
        
        // check if the post is for the currentUser to add delete option
        if user.isCurrentUser {
            results.append(.delete)
        } else {
//            if user.isFollowed {
//                results.append(.unfollow(user))
//            } else {
//                results.append(.follow(user))
//            }
            // if  not currentUser's post, check the followStatus of the user and add the appropiate followOptions to the array
            let followOption: ActionSheetOptions = user.isFollowed ? .unfollow(user) : .follow(user)
            results.append(followOption)
        }
        results.append(.report)
        return results
    }
    
    // MARK: - Lifecycle
    init(user: UserModel) {
        self.user = user
    }
}
