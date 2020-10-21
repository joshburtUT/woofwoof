//
//  PushNotificationSender.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import Foundation

class PushNotificationSender {

    static func sendPushNotification(toToken token: String, withTitle title: String? = nil, andBody body: String) {
        let key = "key=AAAABukOVwA:APA91bHQF-mZC4tqMgXxhwJtWYuLY3AKWbnVdiw-Qdsp2F4iPb-C_KpOwpoKE8x5nz68bUMH0A-1UAJ9PFP_U_8iOAGk78wWs_lI4cO6XalqFXF_bTSG1GDakKCZstEOG8CDGAftZ_WU"
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        
        let notificationDict: [String: Any] = ["to": token,
                                               "notification": ["title": title,
                                                                "body": body]]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: notificationDict, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            do {
                guard let jsonData = data else { return }
                if let jsonDataDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] {
                    NSLog("JOSH: Received data:\n\(jsonDataDict)")
                }

            } catch let err as NSError {
                print("JOSH: Failed to send Push Notification from Sender with error - \(err.localizedDescription)")
            }
        }
        task.resume()
    }
}
