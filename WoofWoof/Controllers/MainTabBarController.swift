//
//  MainTabBarController.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

enum ActionButtonConfiguration {
    case post
    case message
}


class MainTabBarController: UITabBarController, Alertable {
    
    // MARK: - Properties
    
//    private var buttonConfig: ActionButtonConfiguration = .post
    
    var user: UserModel? {
        didSet {
            // we are using the user from the mainTab to set the feedController since the tab is set first
            guard let nav = viewControllers?.first as? UINavigationController else { return }
            guard let feed = nav.viewControllers.first as? FeedController else { return }
            feed.user = user
        }
    }
    
//    let actionButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.tintColor = .white
//        button.backgroundColor = .darkGreen
//        button.setImage(UIImage(named: "new_tweet"), for: .normal)
//        button.addTarget(self, action: #selector(handleActionButtonTapped), for: .touchUpInside)
//        return button
//    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUserAndConfigureUI()
    }
    
    // MARK: - API
    func fetchUser() {
        guard let currentUid = AuthService.CURRENT_USER?.uid else { return }
        UserService.fetchUser(uid: currentUid) { (user) in
            self.user = user
        }
    }
    func authenticateUserAndConfigureUI() {
        if AuthService.CURRENT_USER == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginVC())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configureViewControllers()
            fetchUser()
        }
    }
    func logout() {
        AuthService.logUserOut(onSuccess: {
            let nav = UINavigationController(rootViewController: LoginVC())
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }) { (logoutError) in
            self.showAlert(withTitle: "Error", andMessage: logoutError!)
        }
    }
    
    // MARK: - Helpers
    func configureViewControllers() {
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let nav1 = configureNavController(image: UIImage(systemName: "house"), rootViewController: feed)
        
        let search = SearchController(config: .userSearch)
        let nav2 = configureNavController(image: UIImage(systemName: "magnifyingglass"), rootViewController: search)

        let notification = NotificationController()
        let nav3 = configureNavController(image: UIImage(systemName: "heart"), rootViewController: notification)

        let message = ConversationsController()
        let nav4 = configureNavController(image: UIImage(systemName: "envelope"), rootViewController: message)

        viewControllers = [nav1, nav2, nav3, nav4]
                
        tabBar.tintColor = .myButtonColor
        self.delegate = self // Sets the tabBar delegate
    }
    func configureNavController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        nav.navigationBar.barTintColor = .white
        return nav
    }
}


// MARK: - TabBar Controller Delegate...don't forget to set the delegate (self.delegate = self)
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    }
}

