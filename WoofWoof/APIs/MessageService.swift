//
//  MessageService.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import FirebaseDatabase

struct MessageService {
    static func uploadMessage(_ message: String, toUser user: UserModel, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        let messageDict: [String: Any] = [MESSAGE_TEXT: message,
                                          MESSAGE_TO_ID: user.uid,
                                          MESSAGE_FROM_ID: currentUid,
                                          MESSAGE_TIMESTAMP: timestamp]
        REF_MESSAGES.childByAutoId().updateChildValues(messageDict) { (err, ref) in
            guard let messageId = ref.key else { return }
            
            let messageValue = [messageId: 1]
            let fromMessageRef = REF_USER_MESSAGES.child(currentUid).child(user.uid)
            let toMessageRef = REF_USER_MESSAGES.child(user.uid).child(currentUid)
            
            toMessageRef.updateChildValues(messageValue) { (err, ref) in
                fromMessageRef.updateChildValues(messageValue, withCompletionBlock: completion)
            }
        }
    }
    static func fetchMessage(withMessageId messageId: String, completion: @escaping(Message) -> Void) {
        REF_MESSAGES.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            guard let messageDict = snapshot.value as? [String: Any] else { return }
            guard let fromId = messageDict[MESSAGE_FROM_ID] as? String else { return }
            UserService.fetchUser(uid: fromId) { (user) in
                let message = Message(messageDict: messageDict)
                completion(message)
            }
        }
    }
    static func fetchMessages(withChatPartner chatPartnerId: String, completion: @escaping([Message]) -> Void) {
        var messages = [Message]()
        
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        REF_USER_MESSAGES.child(currentUid).child(chatPartnerId).observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            self.fetchMessage(withMessageId: messageId) { (message) in
                messages.append(message)
                completion(messages)
            }
        }
    }
    static func fetchConversations(completion: @escaping([Conversation]) -> Void) {
        var conversations = [Conversation]()
        
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        // Observe currentUser chatPartners
        REF_USER_MESSAGES.child(currentUid).observe(.childAdded) { (snapshot) in
            let chatPartnerId = snapshot.key
            // Observe last message with chatPartners
            REF_USER_MESSAGES.child(currentUid).child(chatPartnerId).queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
                let messageId = snapshot.key
                fetchMessage(withMessageId: messageId) { (message) in
                    UserService.fetchUser(uid: chatPartnerId) { (user) in
                        let conversation = Conversation(user: user, message: message)
                        conversations.append(conversation)
                        completion(conversations)
                    }
                }
            }
        }
    }
}
