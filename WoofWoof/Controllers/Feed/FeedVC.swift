//
//  FeedVC.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit
import SDWebImage

// FIXME: Initial Load of feed has the status bar set to black...if tapped or different tab selected it changes to desired white
// FIXME: ProfileImageView doesn't always show the correct borderColor

private let reuseIdentifier = "PostCell"

class FeedController: UICollectionViewController {
    
    // MARK: - Properties
    var user: UserModel? {
        didSet { configureLeftBarButton() }
    }
    private var posts = [Post]() {
        didSet { collectionView.reloadData() }
    }
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .myActionButtonTintColor
        button.backgroundColor = .myActionButtonBackgroundColor
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(handleActionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchPosts()
        setUserFCMToken()
    }
    
    
    // MARK: - API
    func fetchPosts() {
        // FIXME: Refresh Control Need to Begin
//        collectionView.refreshControl?.beginRefreshing()
        PostService.fetchPosts { (posts) in
            // FIXME: Refresh Control Nedd to End
            // Need to set the closure posts to the class posts
            self.posts = posts
            // Then sort the posts in reverse order by time
            self.posts = posts.sorted(by: { $0.timestamp > $1.timestamp })
            // Then check if the user has liked any posts...needs to happen after the array has been sorted to match the correct UI vs Array Index
            self.checkIfUserLikedPost()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    func checkIfUserLikedPost() {
        self.posts.forEach { (post) in
            PostService.checkIfUserLikedPost(post) { (didLike) in
                guard didLike == true else { return }
                if let index = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                    self.posts[index].didLike = true
                }
            }
        }
    }
    func setUserFCMToken() {
        CloudMessagingService.setUserFCMToken()
    }
    
    // MARK: - Helpers
    func configureUI() {
        configureNavBar()
        configureCollectionView()
        configureRefreshControl()
        configureActionButtonUI()
    }
    func configureNavBar() {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFill
        imageView.setDimensions(width: 50, height: 50) // need to prevent the image from shifting when the profileImage is added
        configureNavigationBar(withTitle: nil, orWithImageView: imageView, prefersLargeTitles: false)
    }
    func configureLeftBarButton() {
        guard let user = user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 40, height: 40)
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 40 / 2
        profileImageView.layer.borderWidth = 1.25
        profileImageView.layer.borderColor = UIColor.myButtonColor.cgColor
        
        profileImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCurrentUserProfileImageTapped))
        profileImageView.addGestureRecognizer(tap)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    func configureCollectionView() {
        collectionView.backgroundColor = .myBackgroundColor
        
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
//        let refreshControl = UIRefreshControl()
//        collectionView.refreshControl = refreshControl
//        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    func configureActionButtonUI() {
        view.addSubview(actionButton)
        actionButton.setDimensions(width: 56, height: 56)
        actionButton.layer.cornerRadius = 56 / 2
        actionButton.layer.borderWidth = 2.0
        actionButton.layer.borderColor = UIColor.white.cgColor
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
                            paddingBottom: 32, paddingRight: 16)
    }

    
    // MARK: - Selectors
    @objc func handleRefresh() {
        fetchPosts()
    }
    @objc func handleCurrentUserProfileImageTapped() {
        guard let user = self.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    @objc func handleActionButtonTapped() {
        guard let user = self.user else { return }
        let controller = UploadController(user: user, config: .post)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
}


// MARK: CollectionView DataSource & Delegate
extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCell
        cell.post = posts[indexPath.item]
        cell.delegate = self
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.item]
        let controller = PostVC(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
}


// MARK: CollectionView Delegate Flow Layout
extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = posts[indexPath.item]
        let viewModel = PostViewModel(post: post)
        let height = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 80)
    }
}


// MARK: - Post Cell Delegate
extension FeedController: PostCellDelegate {
    func handleShareTapped(_ cell: PostCell) {
        guard let post = cell.post else { return }
        guard let user = self.user else { return }
        let controller = FollowLikeController(user: user, postId: post.postId, viewingMode: .Share)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleRetweetTapped(_ cell: PostCell) {
        guard let post = cell.post else { return }
        PostService.retweetPost(post: post) { (err, ref) in
            cell.post?.didRetweet.toggle()
            let retweets = post.didRetweet ? post.retweets - 0 : post.retweets + 1
            cell.post?.retweets = retweets
        }
    }
    func handleFetchUser(withUsername username: String) {
        UserService.fetchUser(withUsername: username) { (user) in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func handleLikeTapped(_ cell: PostCell) {
        guard let post = cell.post else { return }
        PostService.likePost(post: post) { (err, ref) in
            // Need to update the value on the cell as well as the DB
            cell.post?.didLike.toggle()
            let likes = post.didLike ? post.likes - 1 : post.likes + 1
            // Set the value on the cell after the API call has been completed
            cell.post?.likes = likes
            
            // only upload notification if tweet is being liked...since the Post is not being toggled (cell is), we need to negate the didLike value
            guard !post.didLike else { return }
            NotificationService.uploadNotification(toUser: post.user, type: .like, postId: post.postId)
        }
    }
    func handleReplyTapped(_ cell: PostCell) {
        guard let post = cell.post else { return }
        let controller = UploadController(user: post.user, config: .reply(post))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    func handleProfileImageTapped(_ cell: PostCell) {
        guard let user = cell.post?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
