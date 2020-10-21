//
//  ConversationVC.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "ConversationCell"

class ConversationsController: UIViewController {
    
    
    // MARK: - Properties
    private let tableView = UITableView()
    
    private var conversations = [Conversation]()
    private var conversationsDictionary = [String: Conversation]()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .myActionButtonTintColor
        button.backgroundColor = .myActionButtonBackgroundColor
        button.setImage(UIImage(named: "mail"), for: .normal)
        button.addTarget(self, action: #selector(showNewMessage), for: .touchUpInside)
        return button
    }()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchConversations()
    }

    
    // MARK: - API
    func fetchConversations() {
        MessageService.fetchConversations { (conversations) in
            conversations.forEach { (conversation) in
                let message = conversation.message
                self.conversationsDictionary[message.chatPartnerId] = conversation
            }
            self.conversations = Array(self.conversationsDictionary.values)
            self.tableView.reloadData()
        }
    }

    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .myBackgroundColor
        configureNavBar()
        configureTableView()
        configureActionButtonUI()
    }
    func configureNavBar() {
        navigationController?.navigationBar.barStyle = .black

        configureNavigationBar(withTitle: "Messages", prefersLargeTitles: true)
        navigationController?.navigationBar.tintColor = .white

    }
    func configureTableView() {
        tableView.backgroundColor = .myBackgroundColor
        tableView.rowHeight = 80
        tableView.register(ConversationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.frame = view.frame
    }
    func configureActionButtonUI() {
        view.addSubview(actionButton)
        actionButton.setDimensions(width: 56, height: 56)
        actionButton.layer.cornerRadius = 56 / 2
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
                            paddingBottom: 32, paddingRight: 16)
    }
    func showChatController(forUser user: UserModel) {
        let controller = ChatController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Selectors
    @objc func showNewMessage() {
        let controller = SearchController(config: .messages)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
}


// MARK: - Table View Data Source
extension ConversationsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ConversationCell
        cell.conversation = conversations[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - Table View Delegate
extension ConversationsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = conversations[indexPath.row].user
        showChatController(forUser: user)
    }
}

// MARK: - Conversation Controller Delegate
extension ConversationsController: SearchControllerDelegate {
    func controller(_ controller: SearchController, wantsToStartChatWith user: UserModel) {
        dismiss(animated: true, completion: nil)
        showChatController(forUser: user)
    }
}

