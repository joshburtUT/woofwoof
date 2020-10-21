//
//  PostVC.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PostCell"
private let headerIdentifier = "PostHeader"

class PostVC: UICollectionViewController, Alertable {
    
    // MARK: - Properties
    private let post: Post
    private var replies = [Post]() {
        didSet { collectionView.reloadData() }
    }
    
    private var actionSheetLauncher: ActionSheetLauncher!
    
    // MARK: - Lifecycle
    init(post: Post) {
        self.post = post
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchReplies()
    }
    
    
    // MARK: - API
    func fetchReplies() {
        PostService.fetchReplies(forPost: post) { (replies) in
            self.replies = replies
        }
    }
    
    
    // MARK: - Helpers
    func configureCollectionView() {
        collectionView.backgroundColor = .myBackgroundColor
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(PostHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    fileprivate func showActionSheet(forUser user: UserModel) {
        actionSheetLauncher = ActionSheetLauncher(user: user)
        actionSheetLauncher.delegate = self
        actionSheetLauncher.show()
    }
}


// MARK: CollectionView Data Source
extension PostVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCell
        cell.post = replies[indexPath.item]
        return cell
    }
    
}


// MARK: CollectionView Delegate
extension PostVC {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! PostHeader
        header.post = post
        header.delegate = self
        return header
    }
}



// MARK: - CollectionView Delegate Flow Layout
extension PostVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let viewModel = PostViewModel(post: post)
        let captionHeight = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: captionHeight + 260)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}


// MARK: - Post Header Delegate
extension PostVC: PostHeaderDelegate {
    func handleReplytapped(_ header: PostHeader) {
        guard let post = header.post else { return }
        let controller = UploadController(user: post.user, config: .reply(post))
        let nav = UINavigationController(rootViewController: controller)
        navigationController?.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    func handleLikeTapped(_ header: PostHeader) {
        guard let post = header.post else { return }
        PostService.likePost(post: post) { (err, ref) in
            header.post?.didLike.toggle()
            let likes = post.didLike ? post.likes - 1 : post.likes + 1
            header.post?.likes = likes
            guard !post.didLike else { return }
            NotificationService.uploadNotification(toUser: post.user, type: .like, postId: post.postId)
        }
    }
    func handleRetweetTapped(_ header: PostHeader) {
        guard let post = header.post else { return }
        PostService.retweetPost(post: post) { (err, ref) in
            header.post?.didRetweet.toggle()
            let retweet = post.didRetweet ? post.retweets - 0 : post.retweets + 1
            header.post?.retweets = retweet
        }
    }
    func handleProfileImageTapped(_ header: PostHeader) {
        let controller = ProfileController(user: post.user)
        navigationController?.pushViewController(controller, animated: true)
    }
    func showLikes(_ header: PostHeader) {
        let postId = header.post?.postId
        let controller = FollowLikeController(user: post.user, postId: postId, viewingMode: ViewingMode.Likes)
        navigationController?.pushViewController(controller, animated: true)
    }
    func showRetweets(_ header: PostHeader) {
        let controller = FollowLikeController(user: post.user, viewingMode: ViewingMode.Retweets)
        navigationController?.pushViewController(controller, animated: true)
    }
    func handleFetchUser(withUsername username: String) {
        UserService.fetchUser(withUsername: username) { (user) in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func showActionSheet() {
        if post.user.isCurrentUser {
            showActionSheet(forUser: post.user)
        } else {
            UserService.checkIfUserIsFollowed(uid: post.user.uid) { (isFollowed) in
                var user = self.post.user
                user.isFollowed = isFollowed
                self.showActionSheet(forUser: user)
            }
        }
    }
}


// MARK: - Action Sheet Launcher Delegate
extension PostVC: ActionSheetLauncherDelegate {
    // TODO: Setup actions for Report & Delete & Block User
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .follow(let user):
            UserService.followUser(uid: user.uid) { (err, ref) in }
        case .unfollow(let user):
            UserService.unfollowUser(uid: user.uid) { (err, ref) in }
        case .report:
            PostService.reportPost(withPostId: post.postId) { (err, ref) in
                self.showAlert(withTitle: "Post Reported", andMessage: "Your report has been added to the post")
            }
        case .delete:
            PostService.deletePost(withPostId: post.postId)
        }
    }
}
