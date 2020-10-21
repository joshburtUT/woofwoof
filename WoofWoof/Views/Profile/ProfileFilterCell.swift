//
//  ProfileFilterCell.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit


class ProfileFilterCell: UICollectionViewCell {
    
    
    // MARK: - Properties
    var option: ProfileFilterOptions! {
        didSet { titleLabel.text = option.description }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .myDetailLabelColor
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    override var isSelected: Bool {
        didSet {
            titleLabel.font = isSelected ? UIFont.preferredFont(forTextStyle: .body) : UIFont.preferredFont(forTextStyle: .footnote)
            titleLabel.textColor = isSelected ? .myButtonColor : .myDetailLabelColor
        }
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .myBackgroundColor
        
        addSubview(titleLabel)
        titleLabel.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
