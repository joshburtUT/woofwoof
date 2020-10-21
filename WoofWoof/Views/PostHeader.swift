//
//  PostHeader.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit
import ActiveLabel

protocol PostHeaderDelegate: class {
    func showActionSheet()
    func handleFetchUser(withUsername username: String)
    func showLikes(_ header: PostHeader)
    func showRetweets(_ header: PostHeader)
    func handleProfileImageTapped(_ header: PostHeader)
    func handleReplytapped(_ header: PostHeader)
    func handleLikeTapped(_ header: PostHeader)
    func handleRetweetTapped(_ header: PostHeader)
}

class PostHeader: UICollectionReusableView {
    
    // MARK: - Properties
    weak var delegate: PostHeaderDelegate?
    
    var post: Post? {
        didSet { configurePost() }
    }
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.setDimensions(width: 48, height: 48)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 48 / 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 2.0
        iv.backgroundColor = .darkGreen
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .myTitleLabelColor
        return label
    }()
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .myDetailLabelColor
        return label
    }()
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.mentionColor = .systemGreen
        // TODO: implement hashtags
        label.hashtagColor = .systemGreen
        return label
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .myDetailLabelColor
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .left
        return label
    }()
    private let optionButton: UIButton = {
        let button = Utilities().configureButton(forSymbol: UIImage(systemName: "chevron.down")!, withWeight: .medium, andTintColor: .myButtonColor)
        button.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        return button
    }()
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.mentionColor = .darkGreen
        // TODO: implement hashtags
        label.hashtagColor = .darkGreen
        return label
    }()

    
    private lazy var retweetsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .myTitleLabelColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleRetweetsTapped))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        return label
    }()
    private lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .myTitleLabelColor

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLikesTapped))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var statsView: UIView = {
        let view = UIView()
        view.backgroundColor = .myBackgroundColor
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = .label
        view.addSubview(topDividerView)
        topDividerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor,
                              paddingLeft: 8, height: 1.0)
        
        let stack = UIStackView(arrangedSubviews: [retweetsLabel, likesLabel])
        stack.axis = .horizontal
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.centerY(inView: view)
        stack.anchor(left: view.leftAnchor, paddingLeft: 16)
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .label
        view.addSubview(bottomDividerView)
        bottomDividerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                                 paddingLeft: 8, height: 1.0)
        
        return view
    }()
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "bubble.right")
        button.tintColor = .myButtonColor
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    private lazy var retweetButton: UIButton = {
        let button = createButton(withImageName: "arrow.2.squarepath")
        button.tintColor = .myButtonColor
        button.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
        return button
    }()
    private lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "heart")
        button.tintColor = .myButtonColor
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    private lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "square.and.arrow.up")
        button.tintColor = .myButtonColor
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
    
    
    // MARK: - API
    
    
    // MARK: - Helpers
    func createButton(withImageName imageName: String) -> UIButton {
        let button = Utilities().configureButton(forSymbol: UIImage(systemName: imageName)!, withWeight: .semibold, andTintColor: .darkGreen)
        button.setImage(UIImage(named: imageName), for: .normal)
        return button
    }
    func configureUI() {
        backgroundColor = .myBackgroundColor
        
        let labelStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        labelStack.axis = .vertical
        labelStack.spacing = -6 // needed to use a negative because the profileImageView was creating extra space
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, labelStack])
        imageCaptionStack.spacing = 12
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor,
                     paddingTop: 16, paddingLeft: 16)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: stack.bottomAnchor, left: leftAnchor, right: rightAnchor,
                            paddingTop: 12, paddingLeft: 16, paddingRight: 16)
        
        addSubview(dateLabel)
        dateLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor,
                         paddingTop: 20, paddingLeft: 16)
        
        addSubview(optionButton)
        optionButton.centerY(inView: stack)
        optionButton.anchor(right: rightAnchor, paddingRight: 8)
        
        addSubview(statsView)
        statsView.anchor(top: dateLabel.bottomAnchor, left: leftAnchor, right: rightAnchor,
                         paddingTop: 12, height: 40)
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton,
                                                         retweetButton,
                                                         likeButton,
                                                         shareButton])
        actionStack.spacing = 72
        
        addSubview(actionStack)
        actionStack.centerX(inView: self)
        actionStack.anchor(top: statsView.bottomAnchor, paddingTop: 12)
        
        configureMentionHandler()
    }
    func configurePost() {
        guard let post = post else { return }
        let viewModel = PostViewModel(post: post)
        
        captionLabel.text = post.caption
        fullnameLabel.text = post.user.fullname
        usernameLabel.text = viewModel.usernameText
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        dateLabel.text = viewModel.headerTimestamp
        
        retweetsLabel.attributedText = viewModel.retweetsAttributedString
        likesLabel.attributedText = viewModel.likesAttributedString
        
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        likeButton.tintColor = viewModel.likeButtonTintColor
        
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
    }
    func configureMentionHandler() {
        captionLabel.handleMentionTap { (username) in
            self.delegate?.handleFetchUser(withUsername: username)
        }
    }

    
    
    // MARK: - Selectors
    @objc func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    @objc func showActionSheet() {
        delegate?.showActionSheet()
    }
    @objc func handleCommentTapped() {
        delegate?.handleReplytapped(self)
    }
    @objc func handleRetweetTapped() {
        delegate?.handleRetweetTapped(self)
    }
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(self)
    }
    @objc func handleShareTapped() {
        // TODO: Add This to someone else's feed
        print("JOSH: Handle Share Tapped")
    }
    @objc func handleRetweetsTapped() {
        delegate?.showRetweets(self)
    }
    @objc func handleLikesTapped() {
        delegate?.showLikes(self)
    }
}
