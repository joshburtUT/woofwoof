//
//  ConversationViewModel.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import Foundation


struct ConversationViewModel {
    
    
    // MARK: - Properties
    private let conversation: Conversation
    
    var profileImageUrl: URL? {
        return conversation.user.profileImageUrl
    }
    var timestamp: String {
        
        if let date = conversation.message.timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            return formatter.string(from: date)
        }
        return ""
    }
    
    
    // MARK: - Lifecycle
    init(conversation: Conversation) {
        self.conversation = conversation
    }
}
