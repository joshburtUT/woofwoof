//
//  ConversationCell.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    // MARK: - Properties
    var conversation: Conversation? {
        didSet { configure() }
    }
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.setDimensions(width: 50, height: 50)
        iv.layer.cornerRadius = 50 / 2
        iv.layer.borderWidth = 1.25
        iv.layer.borderColor = UIColor.myButtonColor.cgColor
        return iv
    }()
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        return label
    }()
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .myTitleLabelColor
        return label
    }()
    private let messageTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .myTitleLabelColor
        return label
    }()
    
    // MARK: - Lifecycle
    override init(style: ConversationCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helpers
    func configure() {
        guard let conversation = conversation else { return }
        let viewModel = ConversationViewModel(conversation: conversation)

        usernameLabel.text = conversation.user.username
        messageTextLabel.text = conversation.message.text
        
        timestampLabel.text = viewModel.timestamp
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
    }
    func configureUI() {
        backgroundColor = .myBackgroundColor
        
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, paddingLeft: 12)
        profileImageView.centerY(inView: self)
        
        let stack = UIStackView(arrangedSubviews: [usernameLabel, messageTextLabel])
        stack.axis = .vertical
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: profileImageView)
        stack.anchor(left: profileImageView.rightAnchor, right: rightAnchor,
                     paddingLeft: 12, paddingRight: 12)
        
        addSubview(timestampLabel)
        timestampLabel.anchor(top: topAnchor, right: rightAnchor,
                              paddingTop: 20, paddingRight: 12)
    }
}

