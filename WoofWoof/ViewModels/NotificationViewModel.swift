//
//  NotificationViewModel.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

struct NotificationViewModel {
    
    // MARK: - Properties
    private let notification: Notification
    private let type: NotificationType
    private let user: UserModel
    
    var notificationMessage: String {
        switch type {
        case .follow: return " started following you"
        case .like: return " liked your tweet"
        case .reply: return " replied to your tweet"
        case .retweet: return " retweeted your tweet"
        case .mention: return " mentioned you in a tweet"
//        case .report: return " your post has been reported"
        }
    }
    var notificationText: NSAttributedString? {
        guard let timestamp = timestamp else { return nil }
        
        let attributedText = NSMutableAttributedString(string: user.username, attributes: [.font : UIFont.boldSystemFont(ofSize: 18),
                                                                                           .foregroundColor: UIColor.myTitleLabelColor])
        attributedText.append(NSAttributedString(string: notificationMessage, attributes: [.font : UIFont.systemFont(ofSize: 16),
                                                                                           .foregroundColor: UIColor.myTitleLabelColor]))
        attributedText.append(NSAttributedString(string: " \(timestamp)", attributes: [.font : UIFont.systemFont(ofSize: 14),
                                                                                       .foregroundColor : UIColor.myDetailLabelColor]))
        return attributedText
    }
    var timestamp: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: notification.timestamp, to: now) ?? ""
    }
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
    var shouldHideFollowButton: Bool {
        return type != .follow
    }
    var followButtonText: String {
        return user.isFollowed ? "Following" : "Follow"
    }
    
    
    // MARK: - Lifecycle
    init(notification: Notification) {
        self.notification = notification
        self.type = notification.type
        self.user = notification.user
    }
    
    
    // MARK: - Helpers
}
