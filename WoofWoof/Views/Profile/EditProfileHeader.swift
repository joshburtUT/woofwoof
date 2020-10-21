//
//  EditProfileHeader.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

protocol EditProfileHeaderDelegate: class {
    func handleChangeProfilePhoto()
}

class EditProfileHeader: UIView {
    
    // MARK: - Properties
    weak var delegate: EditProfileHeaderDelegate?
    
    private let user: UserModel
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 3
        iv.setDimensions(width: 100, height: 100)
        iv.layer.cornerRadius = 100 / 2
        return iv
    }()
    private lazy var changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Profile Photo", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleChangeProfilePhoto), for: .touchUpInside)
        return button
    }()

    

    // MARK: - Lifecycle
    init(user: UserModel) {
        self.user = user
        super.init(frame: .zero)
        configureUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API


    // MARK: - Helpers
    func configureUI() {
        backgroundColor = .darkGreen
        
        addSubview(profileImageView)
        profileImageView.center(inView: self, yConstant: -16)
        
        addSubview(changePhotoButton)
        changePhotoButton.centerX(inView: self, topAnchor: profileImageView.bottomAnchor, paddingTop: 8)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
    }
    

    // MARK: - Selectors
    @objc func handleChangeProfilePhoto() {
        delegate?.handleChangeProfilePhoto()
    }
}
