//
//  FollowLikeCell.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit


class FollowLikeCell: UITableViewCell {


    // MARK: - Properties
    var user: UserModel? {
        didSet { configureUser() }
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
        return iv
    }()
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .myTitleLabelColor
        return label
    }()
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .myDetailLabelColor
        return label
    }()
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setDimensions(width: 90, height: 30)
        button.setTitle("Loading..", for: .normal)
        button.setTitleColor(.myActionButtonTintColor, for: .normal)
        button.backgroundColor = .myButtonColor
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()



    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Helpers
    func configureUser() {
        guard let user = self.user else { return }
        profileImageView.sd_setImage(with: user.profileImageUrl)
        self.fullnameLabel.text = user.fullname
        self.usernameLabel.text = user.username
    }
    func configureUI() {
        backgroundColor = .myBackgroundColor
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        let infoStack = UIStackView(arrangedSubviews: [usernameLabel, fullnameLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 2
        
        addSubview(infoStack)
        infoStack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
        
//        addSubview(followButton)
//        followButton.centerY(inView: infoStack)
//        followButton.anchor(right: rightAnchor, paddingRight: 12)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }

    
    // MARK: - Selectors
    @objc func handleFollowTapped() {
        print("JOSH: Handle Follow Tapped")
    }
}
