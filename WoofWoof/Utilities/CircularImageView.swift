//
//  CircularImageView.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/21/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

open class CircularImageView: UIImageView {
    public init(width: CGFloat, image: UIImage? = nil) {
        super.init(image: image)
        
        contentMode = .scaleAspectFill
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        heightAnchor.constraint(equalToConstant: width).isActive = true
        clipsToBounds = true
        
        backgroundColor = .lightGray
        
        layer.borderWidth = width / 30.0
        layer.borderColor = UIColor.myButtonColor.cgColor
        
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
