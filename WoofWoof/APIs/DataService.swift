//
//  DataService.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import FirebaseDatabase


let REF_POSTS = DB_REF.child("posts")
let REF_USER_POSTS = DB_REF.child("user-posts")

let REF_USER_FOLLOWERS = DB_REF.child("user-followers")
let REF_USER_FOLLOWING = DB_REF.child("user-following")

let REF_POST_REPLIES = DB_REF.child("post-replies")
let REF_USER_REPLIES = DB_REF.child("user-replies")

let REF_USER_LIKES = DB_REF.child("user-likes")
let REF_POST_LIKES = DB_REF.child("post-likes")

let REF_NOTIFICATIONS = DB_REF.child("notifications")

let REF_USERNAME_USER = DB_REF.child("username-user")

let REF_MESSAGES = DB_REF.child("messages")
let REF_USER_MESSAGES = DB_REF.child("user-messages")

let REF_REPORTS = DB_REF.child("reports")
let REF_POST_REPORTS = DB_REF.child("post-reported")

let REF_POST_RETWEETS = DB_REF.child("post-retweets")


typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)

