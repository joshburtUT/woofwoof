//
//  NotificationCell.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

protocol NotificationCellDelegate: class {
    func handleProfileImageTapped(_ cell: NotificationCell)
    func handleFollowButtonTapped(_ cell: NotificationCell)
}

class NotificationCell: UITableViewCell {
    
    
    // MARK: - Properties
    weak var delegate: NotificationCellDelegate?
    
    var notification: Notification? {
        didSet { configureNotification() }
    }
    
    private lazy var profileImageView: CircularImageView = {
        let iv = CircularImageView(width: 40)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    private let notificationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading...", for: .normal)
        button.setTitleColor(.darkGreen, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.darkGreen.cgColor
        button.layer.borderWidth = 2
        button.setDimensions(width: 88, height: 32)
        button.layer.cornerRadius = 32 / 2
        
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureNotificationCell()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API


    // MARK: - Helpers
    func configureNotificationCell() {
        backgroundColor = .myBackgroundColor
        
        let stack = UIStackView(arrangedSubviews: [profileImageView, notificationLabel])
        stack.spacing = 8
        stack.alignment = .center
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        stack.anchor(right: rightAnchor, paddingRight: 12)
        
        addSubview(followButton)
        followButton.centerY(inView: self)
        followButton.anchor(right: rightAnchor, paddingRight: 12)
    }
    func configureNotification() {
        guard let notification = notification else { return }
        let viewModel = NotificationViewModel(notification: notification)
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        notificationLabel.attributedText = viewModel.notificationText
        
        followButton.isHidden = viewModel.shouldHideFollowButton
        followButton.setTitle(viewModel.followButtonText, for: .normal)
    }

    // MARK: - Selectors
    @objc func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    @objc func handleFollowTapped() {
        delegate?.handleFollowButtonTapped(self)
    }
}
