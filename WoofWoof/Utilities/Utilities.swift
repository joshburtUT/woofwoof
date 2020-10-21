//
//  Utilities.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

// TODO: Create a loading view
// TODO: Create a alert struct/enum for non UIViewControllers


class Utilities {
    func inputContainerView(withImage image: UIImage, textField: UITextField) -> UIView {
        let view = UIView()
        let iv = UIImageView()
        
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        iv.image = image
        view.addSubview(iv)
        iv.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                  paddingLeft: 8, paddingBottom: 8)
        
        view.addSubview(textField)
        textField.anchor(left: iv.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                         paddingLeft: 8, paddingBottom: 8)
        
        let dividerView = UIView()
        dividerView.backgroundColor = .white
        view.addSubview(dividerView)
        dividerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                           paddingLeft: 8, height: 0.75)
        return view
    }
    func textField(withPlaceholder placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.textColor = .white
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        return tf
    }
    func attributedButton(_ firstPart: String, _ secondPart: String) -> UIButton {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: firstPart, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                                                                        NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: secondPart, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
                                                                                   NSAttributedString.Key.foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }
    func configureImageView(forSymbol symbol: UIImage, withWeight weight: UIImage.SymbolWeight) -> UIImageView {
        let imageView = UIImageView(image: symbol)
        let configWeight = UIImage.SymbolConfiguration(weight: weight)
        imageView.preferredSymbolConfiguration = configWeight
        return imageView
    }
    func configureButton(forSymbol symbol: UIImage, withWeight weight: UIImage.SymbolWeight, andTintColor tintColor: UIColor) -> UIButton {
        let button = UIButton()
        let configWeight = UIImage.SymbolConfiguration(weight: weight)
        button.setImage(symbol, for: .normal)
        button.tintColor = tintColor
        button.setPreferredSymbolConfiguration(configWeight, forImageIn: .normal)
        return button
    }
}
