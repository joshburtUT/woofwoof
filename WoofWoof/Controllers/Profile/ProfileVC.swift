//
//  ProfileVC.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PostCell"
private let headerIdentifier = "ProfileHeader"

class ProfileController: UICollectionViewController, Alertable {
    
    // TODO: Add mentions for the posts/replies/likes cells
    
    // MARK: - Properties
    private var user: UserModel
//    private var users = [UserModel]()
    
    private var posts = [Post]()
    private var replies = [Post]()
    private var likes = [Post]()
    
    private var selectedFilter: ProfileFilterOptions = .posts {
        didSet { collectionView.reloadData() }
    }
    private var currentDataSource: [Post] {
        switch selectedFilter {
        case .posts: return posts
        case .replies: return replies
        case .likes: return likes
        }
    }
    
    
    // MARK: - Lifecycle
    init(user: UserModel) {
        self.user = user
        // Remember to call super.init with collectionView since this controller is a UICollectionView
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchPosts()
        checkIfUserIsFollowed()
        fetchUserStats()
        fetchLikedPosts()
        fetchReplies()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    // MARK: - API
    func fetchPosts() {
        PostService.fetchPosts(forUser: user) { (posts) in
            self.posts = posts
            self.collectionView.reloadData()
        }
    }
    func checkIfUserIsFollowed() {
        UserService.checkIfUserIsFollowed(uid: user.uid) { (isFollowed) in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    func fetchUserStats() {
        UserService.fetchUserStats(uid: user.uid) { (stats) in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    func fetchLikedPosts() {
        PostService.fetchLikes(forUser: user) { (posts) in
            self.likes = posts
            // gets reloaded when the filterBarOption changes from the didSet property
        }
    }
    func fetchReplies() {
        PostService.fetchReplies(forUser: user) { (posts) in
            self.replies = posts
        }
    }
    
    
    // MARK: - Helpers
    func configureCollectionView() {
        collectionView.backgroundColor = .myBackgroundColor
        collectionView.contentInsetAdjustmentBehavior = .never // Pulls the header to the top over the status bar
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        // TODO: If there arent enough posts to go more than full screen, the last one gets stretched to the bottom
        guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset.bottom = tabHeight
    }
    
    
    // MARK: - Selectors
    
}


// MARK: - CollectionView DataSource & Delegate
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCell
        cell.post = currentDataSource[indexPath.item]
        return cell
    }
}



// MARK: - CollectionView Header & Delegate
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        header.delegate = self
        header.user = user
        return header
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = PostVC(post: currentDataSource[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}


// MARK: - CollectionView Delegate Flow Layout
extension ProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height: CGFloat = 350
        
        if user.bio != nil {
            height += 70
        }
        return CGSize(width: view.frame.width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = PostViewModel(post: currentDataSource[indexPath.item])
        var height = viewModel.size(forWidth: view.frame.width).height + 72
        
        if currentDataSource[indexPath.row].isReply {
            height += 20
        }
        return CGSize(width: view.frame.width, height: height)
    }
}

// MARK: - Profile Header Delegate
extension ProfileController: ProfileHeaderDelegate {
    func showFollowers(_ header: ProfileHeader) {
        let controller = FollowLikeController(user: user, viewingMode: ViewingMode.Followers)
        navigationController?.pushViewController(controller, animated: true)
    }
    func showFollowing(_ header: ProfileHeader) {
        let controller = FollowLikeController(user: user, viewingMode: ViewingMode.Following)
        navigationController?.pushViewController(controller, animated: true)
    }
    func didSelect(filter: ProfileFilterOptions) {
        self.selectedFilter = filter
    }
    func handleEditProfileFollow(_ header: ProfileHeader) {
        if user.isCurrentUser {
            let controller = EditProfileController(user: user)
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
            return
        }
        if user.isFollowed {
            UserService.unfollowUser(uid: user.uid) { (err, ref) in
                self.user.isFollowed = false
                self.collectionView.reloadData()  // Don't forget to reloadData for the updating of the actionButton Title
            }
        } else {
            UserService.followUser(uid: user.uid) { (err, ref) in
                self.user.isFollowed = true
                self.collectionView.reloadData()  // Don't forget to reloadData for the updating of the actionButton Title
                
                NotificationService.uploadNotification(toUser: self.user, type: .follow)
            }
        }
    }
    func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
}


// MARK: - Edit Profile Controller Delegate
extension ProfileController: EditProfileControllerDelegate {
    func handleLogout() {
        AuthService.logUserOut(onSuccess: {
            let nav = UINavigationController(rootViewController: LoginVC())
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }) { (logoutError) in
            self.showAlert(withTitle: "Error", andMessage: logoutError!)
        }
    }
    func controller(_ controller: EditProfileController, wantsToUpdate user: UserModel) {
        self.dismiss(animated: true, completion: nil)
        self.user = user
        self.collectionView.reloadData()
    }
}
