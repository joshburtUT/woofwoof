//
//  Themes.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgba(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha/1)
    }
    
    static let darkGreen = UIColor.rgba(red: 36, green: 117, blue: 81, alpha: 1.0)
    
    static var myBackgroundColor: UIColor {
        return UIColor { traits -> UIColor in
            return traits.userInterfaceStyle == .dark ? darkGreen : white
        }
    }
    static var myTitleLabelColor: UIColor {
        return UIColor { traits -> UIColor in
            return traits.userInterfaceStyle == .dark ? white : label
        }
    }
    static var myDetailLabelColor: UIColor {
        return UIColor { traits -> UIColor in
            return traits.userInterfaceStyle == .dark ? systemGray : systemGray
        }
    }
    static var myButtonColor: UIColor {
        return UIColor { traits -> UIColor in
            return traits.userInterfaceStyle == .dark ? white : darkGreen
        }
    }
    static var myActionButtonBackgroundColor: UIColor {
        return UIColor { traits -> UIColor in
            return traits.userInterfaceStyle == .dark ? white : darkGreen
        }
    }
    static var myActionButtonTintColor: UIColor {
        return UIColor { traits -> UIColor in
            return traits.userInterfaceStyle == .dark ? darkGreen : white
        }
    }
}
