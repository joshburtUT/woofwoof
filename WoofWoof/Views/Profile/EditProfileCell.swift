//
//  EditProfileCell.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

protocol EditProfileCellDelegate: class {
    func updateUserInfo(_ cell: EditProfileCell)
}

class EditProfileCell: UITableViewCell {
    
    // MARK: - Properties
    weak var delegate: EditProfileCellDelegate?
    
    var viewModel: EditProfileViewModel? {
        didSet { configure() }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .myTitleLabelColor
        return label
    }()
    lazy var infoTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.preferredFont(forTextStyle: .body)
        tf.adjustsFontForContentSizeCategory = true
        tf.textAlignment = .left
        tf.textColor = .myButtonColor
        tf.addTarget(self, action: #selector(handleUpdateUserInfo), for: .editingDidEnd)
        return tf
    }()
    let bioTextView: InputTextView = {
        let tv = InputTextView()
        tv.font = UIFont.preferredFont(forTextStyle: .body)
        tv.adjustsFontForContentSizeCategory = true
        tv.textColor = .myBackgroundColor
        tv.placeholderLabel.text = "Bio"
        return tv
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .myBackgroundColor
        
        addSubview(titleLabel)
        titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        titleLabel.centerY(inView: self)
        titleLabel.anchor(top: topAnchor, left: leftAnchor,
                          paddingTop: 12, paddingLeft: 16)
        
        addSubview(infoTextField)
        infoTextField.anchor(top: topAnchor, left: titleLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor,
                             paddingTop: 4, paddingLeft: 12, paddingRight: 12)
        
        addSubview(bioTextView)
        bioTextView.anchor(top: topAnchor, left: titleLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor,
                           paddingTop: 4, paddingLeft: 12, paddingRight: 12)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateUserInfo), name: UITextView.textDidEndEditingNotification, object: nil)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helpers
    func configure() {
        guard let viewModel = viewModel else { return }
        
        infoTextField.isHidden = viewModel.shouldHideTextField
        bioTextView.isHidden = viewModel.shouldHideTextView
        
        titleLabel.text = viewModel.titleText
        infoTextField.text = viewModel.optionValue
        
        bioTextView.placeholderLabel.isHidden = viewModel.shouldHidePlaceholderLabel
        bioTextView.text = viewModel.optionValue
    }
    
    
    // MARK: - Selectors
    @objc func handleUpdateUserInfo() {
        delegate?.updateUserInfo(self)
    }
}
