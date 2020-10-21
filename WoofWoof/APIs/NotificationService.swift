//
//  NotificationService.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import FirebaseDatabase
import FirebaseMessaging


struct NotificationService {
    static func uploadNotification(toUser user: UserModel, type: NotificationType, postId: String? = nil) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        let notificationRef = REF_NOTIFICATIONS.child(user.uid).childByAutoId()
        guard let notificationKey = notificationRef.key else { return }
        
        var notificationDict: [String: Any] = [NOTIFICATION_TIMESTAMP: Int(Date().timeIntervalSince1970),
                                               NOTIFICATION_FROM: currentUid,
                                               NOTIFICATION_TYPE: type.rawValue,
                                               NOTIFICATION_ID: notificationKey]
        if let postId = postId {
            notificationDict[NOTIFICATION_POST_ID] = postId
        }
        // ??? Do I need a completion with the updateChildValues...some times the push doesnt come through
        notificationRef.updateChildValues(notificationDict)
        
        guard let fcmToken = user.fcmToken else { return }
        UserService.fetchUser(uid: currentUid) { (user) in
            PushNotificationSender.sendPushNotification(toToken: fcmToken, withTitle: user.username, andBody: type.description)
            print("JOSH: Push Notification sent to \(fcmToken) from User \(user.username) with a type of \(type.description)")
        }
    }
    static func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        var notifications = [Notification]()
        
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        
        // TODO: Add a check for user-feed is Empty
        REF_NOTIFICATIONS.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            // user has no notifications...complete with an empty notificationsArray
            if !snapshot.exists() {
                completion(notifications)
            } else {
                
                REF_NOTIFICATIONS.child(currentUid).observe(.childAdded) { (snapshot) in
                    guard let notificationDict = snapshot.value as? [String: Any] else { return }
                    guard let uid = notificationDict[NOTIFICATION_FROM] as? String else { return }
                    
                    UserService.fetchUser(uid: uid) { (user) in
                        let notification = Notification(user: user, notificationDict: notificationDict)
                        notifications.append(notification)
                        completion(notifications)
                    }
                }
            }
        }
    }
    static func removeNotifications(withPostId postId: String) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        REF_NOTIFICATIONS.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for snap in snapshot {
                guard let dict = snap.value as? [String: Any] else { return }
                if dict[NOTIFICATION_POST_ID] as? String == postId {
                    REF_NOTIFICATIONS.child(currentUid).child(snap.key).removeValue()
                }
            }
        }
    }
    static func removeNotification(withNotificationId notificationId: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        REF_NOTIFICATIONS.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for snap in snapshot {
                guard let dict = snap.value as? [String: Any] else { return }
                if dict[NOTIFICATION_ID] as? String == notificationId {
                    REF_NOTIFICATIONS.child(currentUid).child(snap.key).removeValue(completionBlock: completion)
                }
            }
        }
    }
}

struct CloudMessagingService {
    static func setUserFCMToken() {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        guard let fcmToken = Messaging.messaging().fcmToken else { return }
        
        let values = ["fcm_token": fcmToken]
        REF_USERS.child(currentUid).updateChildValues(values)
    }
}
