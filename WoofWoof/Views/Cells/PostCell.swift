//
//  PostCell.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit
import ActiveLabel

protocol PostCellDelegate: class {
    func handleProfileImageTapped(_ cell: PostCell)
    func handleReplyTapped(_ cell: PostCell)
    func handleLikeTapped(_ cell: PostCell)
    func handleRetweetTapped(_ cell: PostCell)
    func handleFetchUser(withUsername username: String)
    func handleShareTapped(_ cell: PostCell)
}

class PostCell: UICollectionViewCell {
    
    
    // MARK: - Properties
    weak var delegate: PostCellDelegate?
    
    var post: Post? {
        didSet { configurePost() }
    }
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.setDimensions(width: 48, height: 48)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 48 / 2
        iv.layer.borderWidth = 1.25
        iv.layer.borderColor = UIColor.myButtonColor.cgColor
        iv.backgroundColor = .darkGreen
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
//        label.mentionColor = .lightGreen
        // TODO: implement hashtags
//        label.hashtagColor = .lightGreen
        return label
    }()
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.mentionColor = .darkGreen
        // TODO: implement hashtags
        label.hashtagColor = .darkGreen
        return label
    }()
    
    private let infoLabel = UILabel()
    
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "bubble.right")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    private lazy var retweetButton: UIButton = {
        let button = createButton(withImageName: "arrow.2.squarepath")
        button.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
        return button
    }()
    private lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "heart")
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    private lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "square.and.arrow.up")
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        return button
    }()
    
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helpers
    func configurePost() {
        guard let post = post else { return }
        let viewModel = PostViewModel(post: post)
        
        infoLabel.attributedText = viewModel.userInfoText
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        captionLabel.text = post.caption
        
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
        
        
    }
    func configureMentionHandler() {
        captionLabel.handleMentionTap { (username) in
            self.delegate?.handleFetchUser(withUsername: username)
        }
    }
    func configureUI() {
        backgroundColor = .myBackgroundColor
        
        let captionStack = UIStackView(arrangedSubviews: [infoLabel, captionLabel])
        captionStack.axis = .vertical
        captionStack.distribution = .fillProportionally
        captionStack.spacing = 4
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, captionStack])
        imageCaptionStack.distribution = .fillProportionally
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .leading
        
        addSubview(imageCaptionStack)
        imageCaptionStack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor,
                                 paddingTop: 8, paddingLeft: 12, paddingRight: 12)
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor,
                     paddingTop: 4, paddingLeft: 12, paddingRight: 12)
        
        replyLabel.isHidden = true
        
        infoLabel.font = UIFont.systemFont(ofSize: 16)
        infoLabel.textColor = .myTitleLabelColor
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton,
                                                         retweetButton,
                                                         likeButton,
                                                         shareButton])
        actionStack.spacing = 72
        addSubview(actionStack)
        actionStack.centerX(inView: self)
        actionStack.anchor(bottom: bottomAnchor, paddingBottom: 8)
        
        let underlineView = UIView()
        underlineView.backgroundColor = .myBackgroundColor
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 1)
        
        configureMentionHandler()
    }
    func createButton(withImageName imageName: String) -> UIButton {
        let button = Utilities().configureButton(forSymbol: UIImage(systemName: imageName)!, withWeight: .semibold, andTintColor: .myButtonColor)
        button.setImage(UIImage(named: imageName), for: .normal)
        return button
    }
    
    // MARK: - Selectors
    @objc func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    @objc func handleCommentTapped() {
        delegate?.handleReplyTapped(self)
    }
    @objc func handleRetweetTapped() {
        delegate?.handleRetweetTapped(self)
    }
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(self)
    }
    @objc func handleShareTapped() {
        delegate?.handleShareTapped(self)
    }
}
