//
//  PostService.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import FirebaseDatabase

struct PostService {
    static func reportPost(withPostId postId: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        let reportPostDict: [String: Any] = [REPORT_USER_ID: currentUid,
                                             REPORT_POST_ID: postId,
                                             REPORT_TIMESTAMP: timestamp,
                                             REPORT_COUNT: 0]
        let reportRef = REF_REPORTS.childByAutoId()
        reportRef.updateChildValues(reportPostDict) { (err, ref) in
            guard let reportId = ref.key else { return }
            REF_POST_REPORTS.child(postId).updateChildValues([currentUid: reportId], withCompletionBlock: completion)
        }
    }
    static func uploadPost(caption: String, type: UploadPostConfiguration, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        var postDict: [String: Any] = [POST_CAPTION: caption,
                                       POST_OWNER: currentUid,
                                       POST_TIMESTAMP: timestamp,
                                       POST_LIKES: 0,
                                       POST_RETWEETS: 0]
        switch type {
        case .post:
            // Uploads a post to the post structure, then in the completion it will upload to user-post structure
            REF_POSTS.childByAutoId().updateChildValues(postDict) { (err, ref) in
                guard let postID = ref.key else { return }
                REF_USER_POSTS.child(currentUid).updateChildValues([postID: 1], withCompletionBlock: completion)
            }
        case .reply(let post):
            postDict[POST_REPLYING_TO] = post.user.username
            REF_POST_REPLIES.child(post.postId).childByAutoId().updateChildValues(postDict) { (err, ref) in
                guard let replyId = ref.key else { return }
                REF_USER_REPLIES.child(currentUid).updateChildValues([post.postId: replyId], withCompletionBlock: completion)
            }
        }
    }
    // TODO: Make a user-feed structure, user -> following & self
    static func fetchPosts(completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        // Following User Posts
        REF_USER_FOLLOWING.child(currentUid).observe(.childAdded) { (followingSnapshot) in
            let followingUid = followingSnapshot.key
            REF_USER_POSTS.child(followingUid).observe(.childAdded) { (postSnapshot) in
                let postId = postSnapshot.key
                self.fetchPost(withPostId: postId) { (post) in
                    posts.append(post)
                    completion(posts)
                }
            }
        }
        // Append Current Posts
        REF_USER_POSTS.child(currentUid).observe(.childAdded) { (currentUserSnapshot) in
            let postId = currentUserSnapshot.key
            self.fetchPost(withPostId: postId) { (post) in
                posts.append(post)
                completion(posts)
            }
        }
        // Append Shared Posts
        //        self.sharePost(postId: <#T##String#>, withUserId: <#T##String#>, completion: <#T##(Post) -> Void#>)
        
    }
    static func fetchPosts(forUser user: UserModel, completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        
        REF_USER_POSTS.child(user.uid).observe(.childAdded) { (userPostsSnapshot) in
            let postID = userPostsSnapshot.key
            REF_POSTS.child(postID).observeSingleEvent(of: .value) { (postsSnapshot) in
                guard let postDict = postsSnapshot.value as? [String: Any] else { return }
                guard let postOwnerId = postDict[POST_OWNER] as? String else { return }
                
                UserService.fetchUser(uid: postOwnerId) { (user) in
                    let post = Post(user: user, postId: postID, postDict: postDict)
                    posts.append(post)
                    completion(posts)
                }
            }
        }
    }
    static func fetchPost(withPostId postID: String, completion: @escaping(Post) -> Void) {
        REF_POSTS.child(postID).observeSingleEvent(of: .value) { (postsSnapshot) in
            guard let postDict = postsSnapshot.value as? [String: Any] else { return }
            guard let postOwnerId = postDict[POST_OWNER] as? String else { return }
            
            UserService.fetchUser(uid: postOwnerId) { (user) in
                let post = Post(user: user, postId: postID, postDict: postDict)
                completion(post)
            }
        }
    }
    static func fetchReplies(forPost post: Post, completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        
        REF_POST_REPLIES.child(post.postId).observe(.childAdded) { (snapshot) in
            guard let postDict = snapshot.value as? [String: Any] else { return }
            guard let postOwnerId = postDict[POST_OWNER] as? String else { return }
            let postID = snapshot.key
            
            UserService.fetchUser(uid: postOwnerId) { (user) in
                let post = Post(user: user, postId: postID, postDict: postDict)
                posts.append(post)
                completion(posts)
            }
        }
    }
    static func fetchReplies(forUser user: UserModel, completion: @escaping([Post]) -> Void) {
        var replies = [Post]()
        
        REF_USER_REPLIES.child(user.uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            guard let replyId = snapshot.value as? String else { return }
            
            REF_POST_REPLIES.child(postId).child(replyId).observeSingleEvent(of: .value) { (snapshot) in
                guard let postDict = snapshot.value as? [String: Any] else { return }
                guard let postOwnerId = postDict[POST_OWNER] as? String else { return }
                let replyKey = snapshot.key
                
                UserService.fetchUser(uid: postOwnerId) { (user) in
                    let reply = Post(user: user, postId: replyKey, postDict: postDict)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
    }
    static func retweetPost(post: Post, completion: @escaping(DatabaseCompletion)) {
        let postId = post.postId
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        REF_POSTS.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            guard let postDict = snapshot.value as? [String: Any] else { return }
            let postOwner = postDict[POST_OWNER] as? String
            if postOwner != currentUid {
                REF_POSTS.child(postId).child(POST_RETWEETS).observeSingleEvent(of: .value) { (snapshot) in
                    guard var retweetCount = snapshot.value as? Int else { return }
                    retweetCount += 1
                    REF_POSTS.child(postId).updateChildValues([POST_RETWEETS: retweetCount])
                }
                REF_POST_RETWEETS.child(postId).setValue([currentUid: 1], withCompletionBlock: completion)
            }
        }
    }
    static func deletePost(withPostId postId: String) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        
        // remove from followers feed
        REF_USER_FOLLOWERS.child(currentUid).observe(.childAdded) { (snapshot) in
            //            print("JOSH: User-Followers = \(snapshot)")
            let followerUid = snapshot.key
            REF_USER_POSTS.child(followerUid).child(postId).removeValue()
        }
        // remove from current user feed
        REF_USER_POSTS.child(currentUid).child(postId).removeValue()
        
        // remove from post-likes
        REF_POST_LIKES.child(postId).removeValue()
        
        // remove from user-likes
        REF_USER_LIKES.observe(.childAdded) { (snapshot) in
            //            print("JOSH: User-Likes - \(snapshot)")
            let userId = snapshot.key
            REF_USER_LIKES.child(userId).child(postId).removeValue()
        }
        // remove from post replies
        REF_POST_REPLIES.child(postId).removeValue()
        
        // remove from user replies
        REF_USER_REPLIES.observe(.childAdded) { (snapshot) in
            //            print("JOSH: User-Replies - \(snapshot)")
            let userId = snapshot.key
            REF_USER_REPLIES.child(userId).child(postId).removeValue()
        }
        
        // remove notifications
        NotificationService.removeNotifications(withPostId: postId)
        
        // TODO: remove post-retweets??
        REF_POST_RETWEETS.child(postId).removeValue()
        
        // remove the actual post
        REF_POSTS.child(postId).removeValue()
    }
    
    
    
    // MARK: - LIKES
    static func likePost(post: Post, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        //        let postId = post.postId
        
        // update the like count, then set it in the DB
        let likes = post.didLike ? post.likes - 1 : post.likes + 1
        REF_POSTS.child(post.postId).child(POST_LIKES).setValue(likes)
        
        if post.didLike {
            // unlike post
            REF_USER_LIKES.child(currentUid).child(post.postId).removeValue { (err, ref) in
                REF_POST_LIKES.child(post.postId).removeValue(completionBlock: completion)
            }
        } else {
            // like post
            REF_USER_LIKES.child(currentUid).updateChildValues([post.postId: 1]) { (err, ref) in
                REF_POST_LIKES.child(post.postId).updateChildValues([currentUid: 1], withCompletionBlock: completion)
            }
        }
    }
    static func fetchLikes(forUser user: UserModel, completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        
        REF_USER_LIKES.child(user.uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            self.fetchPost(withPostId: postId) { (likedPost) in
                
                // create a mutatable copy so we can modify the didLiked property of the tweet
                var post = likedPost
                post.didLike = true
                posts.append(post)
                completion(posts)
            }
        }
    }
    static func fetchLikes(forPost post: Post, completion: @escaping([UserModel]) -> Void) {
        var users = [UserModel]()
        REF_POST_LIKES.child(post.postId).observe(.childAdded) { (snapshot) in
            let userId = snapshot.key
            UserService.fetchUser(uid: userId) { (user) in
                users.append(user)
                completion(users)
            }
        }
    }
    static func fetchRetweets(forPost post: Post, completion: @escaping([UserModel]) -> Void) {
        var users = [UserModel]()
        REF_POST_RETWEETS.child(post.postId).observe(.childAdded) { (snapshot) in
            let userId = snapshot.key
            UserService.fetchUser(uid: userId) { (user) in
                users.append(user)
                completion(users)
            }
        }
    }
    static func sharePost(postId: String, withUserId uid: String, completion: @escaping(Post) -> Void) {
        self.fetchPost(withPostId: postId) { (post) in
            REF_USER_POSTS.child(uid).updateChildValues([postId: 1])
            completion(post)
        }
    }
    static func checkIfUserLikedPost(_ post: Post, completion: @escaping(Bool) -> Void) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        REF_USER_LIKES.child(currentUid).child(post.postId).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
}
