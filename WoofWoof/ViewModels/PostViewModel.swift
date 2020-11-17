//
//  PostViewModel.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit


struct PostViewModel {
    
    // MARK: - Properties
    let post: Post
    let user: UserModel
    
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: post.timestamp, to: now) ?? "2m"
    }
    
    var usernameText: String {
        return "@\(user.username)"
    }
    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a • MM/dd/yyyy"
        return formatter.string(from: post.timestamp)
    }
    var retweetsAttributedString: NSAttributedString? {
        return attributedText(withValue: post.retweets, text: "Retweets")
    }
    var likesAttributedString: NSAttributedString? {
        return attributedText(withValue: post.likes, text: "Likes")
    }

    // TODO: Add Dynamic Type for NSAttributedString
    var userInfoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullname, attributes: [.font: UIFont.boldSystemFont(ofSize: 18),
                                                                                  .foregroundColor: UIColor.myTitleLabelColor])
        title.append(NSAttributedString(string: " @\(user.username)", attributes: [.font: UIFont.systemFont(ofSize: 18),
                                                                                   .foregroundColor: UIColor.lightGray]))
        title.append(NSAttributedString(string: " • \(self.timestamp)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                   .foregroundColor: UIColor.lightGray]))
        return title
    }
    
    var likeButtonTintColor: UIColor {
        return post.didLike ? .myButtonColor : .myButtonColor
    }
    var likeButtonImage: UIImage {
        let imageName = post.didLike ? "heart.fill" : "heart"
        return UIImage(named: imageName)!
    }
    
    var shouldHideReplyLabel: Bool {
        return !post.isReply
    }
    var replyText: String? {
        guard let replyingToUsername = post.replyingTo else { return nil }
        return "→replying to @\(replyingToUsername)"
    }
    
    // MARK: - Lifecycle
    init(post: Post) {
        self.post = post
        self.user = post.user
    }
    
    
    // MARK: - Helpers
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font : UIFont.boldSystemFont(ofSize: 16),
                                                                                         .foregroundColor: UIColor.myTitleLabelColor])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font : UIFont.systemFont(ofSize: 14),
                                                                                   .foregroundColor : UIColor.lightGray]))
        return attributedTitle
    }
    func size(forWidth width: CGFloat) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.text = post.caption
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
