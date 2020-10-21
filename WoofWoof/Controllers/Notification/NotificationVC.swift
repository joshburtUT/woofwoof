//
//  NotificationVC.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationController: UITableViewController {
    
    // TODO: Add a check that a duplicate notification is not created...and purge the database for dupes
    
    // MARK: - Properties
    private var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchNotifications()
    }
    
    // MARK: - API
    func fetchNotifications() {
        //FIXME: - Needed to comment out refresh with the largeTitles
        refreshControl?.beginRefreshing()
        NotificationService.fetchNotifications { (notifications) in
            self.refreshControl?.endRefreshing()
            self.notifications = notifications
            self.checkIfUserIsFollowed(notifications: notifications)
        }
    }
    // Used to check if we need to update the tableView with a follow button
    func checkIfUserIsFollowed(notifications: [Notification]) {
        // Check that there are notifications before checking ... TODO: Need to ask question about if we let the user delete notifications
        guard !notifications.isEmpty else { return }
        
        notifications.forEach { (notification) in
            guard case .follow = notification.type else { return }
            let user = notification.user
                
            UserService.checkIfUserIsFollowed(uid: user.uid) { (isFollowed) in
                if let index = self.notifications.firstIndex(where: { $0.user.uid == notification.user.uid }) {
                    self.notifications[index].user.isFollowed = isFollowed
                }
            }
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        navigationController?.navigationBar.barStyle = .black

        configureNavigationBar(withTitle: "Notifications", prefersLargeTitles: true)
        configureTableView()
    }
    func configureTableView() {
        tableView.backgroundColor = .myBackgroundColor
        tableView.rowHeight = 60
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    
    
    // MARK: - Selectors
    @objc func handleRefresh() {
        fetchNotifications()
    }
}


// MARK: - TableView Data Source
extension NotificationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.delegate = self
        cell.selectionStyle = .none
        cell.notification = notifications[indexPath.row]
        return cell
    }
}


// MARK: - TableView Delegate
extension NotificationController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        guard let postId = notification.postId else { return }
        
        PostService.fetchPost(withPostId: postId) { (post) in
            let controller = PostVC(post: post)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notification = notifications[indexPath.row]

            NotificationService.removeNotification(withNotificationId: notification.notificationId) { (err, ref) in
                self.notifications.remove(at: indexPath.row)
            }
        }
    }
}


// MARK: - Notification Cell Delegate
extension NotificationController: NotificationCellDelegate {
    func handleFollowButtonTapped(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        if user.isFollowed {
            UserService.unfollowUser(uid: user.uid) { (err, ref) in
                cell.notification?.user.isFollowed = false
            }
        } else {
            UserService.followUser(uid: user.uid) { (err, ref) in
                cell.notification?.user.isFollowed = true
            }
        }
    }
    func handleProfileImageTapped(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}


