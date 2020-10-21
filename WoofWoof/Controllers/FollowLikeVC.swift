//
//  FollowLikeVC.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

private let reuseIdentifier = "FollowLikeCell"

enum ViewingMode: Int, CaseIterable {
    case Followers
    case Following
    case Likes
    case Retweets
    case Share
    
    var description: String {
        switch self {
        case .Followers: return "Followers"
        case .Following: return "Following"
        case .Likes: return "Likes"
        case .Retweets: return "Retweets"
        case .Share: return "Share"
        }
    }
}

class FollowLikeController: UITableViewController {
    
    // MARK: - Properties
    private var postId: String?
    private var user: UserModel
    private var viewingMode: ViewingMode!

    private var followers = [UserModel]() {
        didSet { tableView.reloadData() }
    }
    private var following = [UserModel]() {
        didSet { tableView.reloadData() }
    }
    private var likes = [UserModel]() {
        didSet { tableView.reloadData() }
    }
    private var retweets = [UserModel]() {
        didSet { tableView.reloadData() }
    }
    
    
    // MARK: - Lifecycle
    init(user: UserModel, postId: String? = nil, viewingMode: ViewingMode) {
        self.user = user
        self.postId = postId
        self.viewingMode = viewingMode
        super.init(style: .plain)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        navigationItem.title = viewingMode.description
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchUser(forViewingMode: viewingMode)
    }
    
    
    // MARK: - API
    func sharePost(withUser user: UserModel) {
        guard let postId = self.postId else { return }
        print("JOSH: Post Id - \(postId)")
        PostService.sharePost(postId: postId, withUserId: user.uid) { (post) in
            
        }
    }
    

    // MARK: - Helpers
    func fetchUser(forViewingMode viewingMode: ViewingMode) {
        switch viewingMode {
            
        case .Followers, .Share:
            UserService.fetchUserFollowers(forUser: user) { (followers) in
                self.followers = followers
                self.tableView.reloadData()
            }
        case .Following:
            UserService.fetchUserFollowing(forUser: user) { (following) in
                self.following = following
                self.tableView.reloadData()
            }
        case .Likes:
            guard let postId = postId else { return }
            UserService.fetchUserLikedPost(forPostId: postId) { (likes) in
                self.likes = likes
                self.tableView.reloadData()
            }
        case .Retweets:
            guard let postId = postId else { return }
            UserService.fetchUserRetweetedPost(forPostId: postId) { (retweets) in
                self.retweets = retweets
                self.tableView.reloadData()
            }
        }
    }
    func configureTableView() {
        tableView.backgroundColor = .myBackgroundColor
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
    }
}

// MARK: - TableView Data Source
extension FollowLikeController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewingMode {
        case .Followers, .Share: return followers.count
        case .Following: return following.count
        case .Likes: return likes.count
        case .Retweets: return retweets.count
        case .none: print("Nothing")
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowLikeCell
        switch viewingMode {
        case .Followers: cell.user = followers[indexPath.row]
        case .Following: cell.user = following[indexPath.row]
        case .Likes: cell.user = likes[indexPath.row]
        case .Retweets: cell.user = retweets[indexPath.row]
        case .Share: cell.user = followers[indexPath.row]
        case .none: print("Nothing")
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var user: UserModel?
        switch viewingMode {
        case .Followers: user = followers[indexPath.row]
        case .Following: user = following[indexPath.row]
        case .Likes: user = likes[indexPath.row]
        case .Retweets: user = retweets[indexPath.row]
        case .Share: user = followers[indexPath.row]
        guard let user = user else { return }
            sharePost(withUser: user)
            print("JOSH: Share Post \(postId) with User \(user.username)")
        case .none: print("Nothing")
        }

        if let user = user {
            let controller = ProfileController(user: user)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

