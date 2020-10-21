//
//  ProfileHeader.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

protocol ProfileHeaderDelegate: class {
    func handleDismissal()
    func handleEditProfileFollow(_ header: ProfileHeader)
    func showFollowers(_ header: ProfileHeader)
    func showFollowing(_ header: ProfileHeader)
    func didSelect(filter: ProfileFilterOptions)
}


class ProfileHeader: UICollectionReusableView {
    
    
    // MARK: - Properties
    weak var delegate: ProfileHeaderDelegate?
    
    var user: UserModel? {
        didSet { configure() }
    }
    
    private let filterBar = ProfileFilterView()
    
    private lazy var containerView: UIView = { // Custom NavBar since we hide the standard one
        let view = UIView()
        view.backgroundColor = .darkGreen
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor, left: view.leftAnchor,
                          paddingTop: 42, paddingLeft: 16)
        backButton.setDimensions(width: 30, height: 30)
        return view
    }()
    private lazy var backButton: UIButton = {
        let button = Utilities().configureButton(forSymbol: UIImage(systemName: ICON_ARROW_LEFT)!, withWeight: .medium, andTintColor: .white)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    private lazy var profileImageView: CircularImageView = {
        let iv = CircularImageView(width: 80)
        return iv
    }()

    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setDimensions(width: 100, height: 36)
        button.setTitle("Loading...", for: .normal)
        button.tintColor = .myBackgroundColor
        button.layer.borderColor = UIColor.myButtonColor.cgColor
        button.layer.borderWidth = 1.25
        button.layer.cornerRadius = 36 / 2
        button.setTitleColor(.myButtonColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button
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
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .myTitleLabelColor
        label.numberOfLines = 3
        return label
    }()
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .myDetailLabelColor
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.textColor = .myDetailLabelColor
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        filterBar.delegate = self
        
        addSubview(containerView)
        containerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 108)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: containerView.bottomAnchor, left: leftAnchor,
                                paddingTop: -24, paddingLeft: 8)
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: containerView.bottomAnchor, right: rightAnchor,
                                       paddingTop: 12, paddingRight: 12)
        
        let userDetailsStack = UIStackView(arrangedSubviews: [fullnameLabel,
                                                              usernameLabel,
                                                              bioLabel])
        userDetailsStack.axis = .vertical
        userDetailsStack.distribution = .fillProportionally
        userDetailsStack.spacing = 4
        
        addSubview(userDetailsStack)
        userDetailsStack.anchor(top: profileImageView.bottomAnchor, left:  leftAnchor, right: rightAnchor,
                                paddingTop: 8, paddingLeft: 12, paddingRight: 12)
        
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
        followStack.distribution = .fillEqually
        followStack.spacing = 8
        
        addSubview(followStack)
        followStack.anchor(top: userDetailsStack.bottomAnchor, left: leftAnchor,
                           paddingTop: 8, paddingLeft: 12)
        
        addSubview(filterBar)
        filterBar.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 50)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - API
    
    
    // MARK: - Helpers
    func configure() {
        guard let user = user else { return }
        let viewModel = ProfileHeaderViewModel(user: user)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
        fullnameLabel.text = user.fullname
        usernameLabel.text = viewModel.usernameText
        bioLabel.text = user.bio
        
        editProfileFollowButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        
        followingLabel.attributedText = viewModel.followingString
        followersLabel.attributedText = viewModel.followersString
    }
    
    
    // MARK: - Selectors
    @objc func handleDismissal() {
        delegate?.handleDismissal()
    }
    @objc func handleEditProfileFollow() {
        delegate?.handleEditProfileFollow(self)
    }
    @objc func handleFollowersTapped() {
        delegate?.showFollowers(self)
    }
    @objc func handleFollowingTapped() {
        delegate?.showFollowing(self)
    }
}


// MARK: - Profile Filter View Delegate
extension ProfileHeader: ProfileFilterViewDelegate {
    func animateFilterView(_ view: ProfileFilterView, didSelect index: Int) {
        guard let filter = ProfileFilterOptions(rawValue: index) else { return }
        delegate?.didSelect(filter: filter)
    }
}
