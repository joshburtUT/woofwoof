//
//  MessageViewModel.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

struct MessageViewModel {
    
    // MARK: - Properties
    private let message: Message
    
    var messageBackgroundColor: UIColor {
        return message.isFromCurrentUser ? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) : .darkGreen
    }
    var messageTextColor: UIColor {
        return message.isFromCurrentUser ? .black : .white
    }
    var rightAnchorActive: Bool {
        return message.isFromCurrentUser
    }
    var leftAnchorActive: Bool {
        return !message.isFromCurrentUser
    }
    var shouldHideProfileImage: Bool {
        return message.isFromCurrentUser
    }
    var profileImageUrl: URL? {
        guard let user = message.user else { return nil }
        return user.profileImageUrl
        
    }

    // MARK: - Lifecycle
    init(message: Message) {
        self.message = message
    }
    
}

