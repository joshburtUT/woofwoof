//
//  UserService.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import FirebaseDatabase

struct UserService {
    static func fetchUser(uid: String, completion: @escaping(UserModel) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userDict = userSnapshot.value as? [String: Any] else { return }
            let user = UserModel(uid: uid, userDict: userDict)
            completion(user)
        }
    }
    static func fetchUsers(completion: @escaping([UserModel]) -> Void) {
        var users = [UserModel]()
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        REF_USERS.observe(.childAdded) { (usersSnapshot) in
            let uid = usersSnapshot.key
            guard let userDict = usersSnapshot.value as? [String: Any] else { return }
            let user = UserModel(uid: uid, userDict: userDict)
            users.append(user)
            
            // Check for currentUser and remove from fetchedUsers
            if let i = users.firstIndex(where: { $0.uid == currentUid }) {
                users.remove(at: i)
            }
            completion(users)
        }
    }
    static func followUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        REF_USER_FOLLOWING.child(currentUid).updateChildValues([uid: 1]) { (err, ref) in
            REF_USER_FOLLOWERS.child(uid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
        }
    }
    // TODO: Add a refresh feed when user unfollows someone with a childRemove listener
    static func unfollowUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        REF_USER_FOLLOWING.child(currentUid).child(uid).removeValue { (err, ref) in
            REF_USER_FOLLOWERS.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
    }
    static func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        REF_USER_FOLLOWING.child(currentUid).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
    // TODO: Combine the two follow fetchs into 1 method...maybe complete with ["followTypeKey": [UserModel]]
    static func fetchUserFollowers(forUser user: UserModel, completion: @escaping([UserModel]) -> Void) {
        var followers = [UserModel]()
        let uid = user.uid
        REF_USER_FOLLOWERS.child(uid).observe(.childAdded) { (followersSnapshot) in
            let uid = followersSnapshot.key
            self.fetchUser(uid: uid) { (user) in
                followers.append(user)
                completion(followers)
            }
        }
    }
    static func fetchUserFollowing(forUser user: UserModel, completion: @escaping([UserModel]) -> Void) {
        var following = [UserModel]()
        let uid = user.uid
        REF_USER_FOLLOWING.child(uid).observe(.childAdded) { (followingSnapshot) in
            let uid = followingSnapshot.key
            self.fetchUser(uid: uid) { (user) in
                following.append(user)
                completion(following)
            }
        }
    }
    static func fetchUserLikedPost(forPostId postId: String, completion: @escaping([UserModel]) -> Void) {
        var likes = [UserModel]()
        REF_POST_LIKES.child(postId).observe(.childAdded) { (likesSnapshot) in
            let uid = likesSnapshot.key
            self.fetchUser(uid: uid) { (user) in
                likes.append(user)
                completion(likes)
            }
        }
    }
    static func fetchUserRetweetedPost(forPostId postId: String, completion: @escaping([UserModel]) -> Void) {
        var retweets = [UserModel]()
        REF_POST_RETWEETS.child(postId).observe(.childAdded) { (retweetsSnapshot) in
            let uid = retweetsSnapshot.key
            self.fetchUser(uid: uid) { (user) in
                retweets.append(user)
                completion(retweets)
            }
        }
    }
    static func fetchUserStats(uid: String, completion: @escaping(UserRelationStats) -> Void) {
        REF_USER_FOLLOWERS.child(uid).observeSingleEvent(of: .value) { (followersSnapshot) in
            let followers = followersSnapshot.children.allObjects.count
            REF_USER_FOLLOWING.child(uid).observeSingleEvent(of: .value) { (followingSnapshot) in
                let following = followingSnapshot.children.allObjects.count
                let stats = UserRelationStats(followers: followers, following: following)
                completion(stats)
            }
        }
    }
    // TODO: Make a new structure for usernames: uids
    static func fetchUser(withUsername username: String, completion: @escaping(UserModel) -> Void) {
        REF_USERNAME_USER.child(username).observeSingleEvent(of: .value) { (snapshot) in
            guard let uid = snapshot.value as? String else { return }
            self.fetchUser(uid: uid, completion: completion)
        }
    }
    
    // User Updates
    static func updateUserData(user: UserModel, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        let userDict: [String: Any] = [USER_FULLNAME: user.fullname,
                                       USER_USERNAME: user.username.lowercased(),
                                       USER_BIO: user.bio ?? ""]
        REF_USERS.child(currentUid).updateChildValues(userDict, withCompletionBlock: completion)
    }
    static func updateProfileImage(image: UIImage, completion: @escaping(String) -> Void) {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        StorageService.uploadUserProfileImage(image: image) { (profileImageUrlString) in
            let imageDict = [USER_PROFILE_IMAGE_URL: profileImageUrlString]
            REF_USERS.child(currentUid).updateChildValues(imageDict) { (err, ref) in
                completion(profileImageUrlString)
            }
        }
    }
}
