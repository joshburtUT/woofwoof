//
//  ActionSheetCell.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

class ActionSheetCell: UITableViewCell {
    
    
    // MARK: - Properties
    var option: ActionSheetOptions? {
        didSet { configureActionSheet() }
    }
    
    private let optionImageView: UIImageView = {
        let iv = Utilities().configureImageView(forSymbol: (UIImage(named: "logo")?.imageWithColor(color: .white))!, withWeight: .medium)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        return label
    }()

    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureActionCell()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Helpers
    func configureActionCell() {
        backgroundColor = .darkGreen
        addSubview(optionImageView)
        optionImageView.centerY(inView: self)
        optionImageView.anchor(left: leftAnchor, paddingLeft: 8)
        optionImageView.setDimensions(width: 36, height: 36)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: self)
        titleLabel.anchor(left: optionImageView.rightAnchor, paddingLeft: 12)
    }
    func configureActionSheet() {
        titleLabel.text = option?.description
    }
}
