//
//  SearchVC.swift
//  
//
//  Created by Josh Burt on 10/20/20.
//

import UIKit

private let reuseIdentifier = "UserCell"

enum SearchControllerConfiguration {
    case messages
    case userSearch
}

protocol SearchControllerDelegate: class {
    func controller(_ controller: SearchController, wantsToStartChatWith user: UserModel)
}

class SearchController: UITableViewController {
    
    
    // MARK: - Properties
    weak var delegate: SearchControllerDelegate?
    
    private let config: SearchControllerConfiguration
    
    
    // TIP: If user array is larger than actual count, check users in FB for extra fcm_token users
    private var users = [UserModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var filteredUsers = [UserModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    init(config: SearchControllerConfiguration) {
        self.config = config
        super.init(style: .plain)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
    }
    
    // MARK: - API
    func fetchUsers() {
        UserService.fetchUsers { (users) in
            self.users = users
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .myBackgroundColor
        configureNavBar()
        configureTableView()
        configureSearchController()
    }
    func configureNavBar() {
        navigationController?.navigationBar.barStyle = .black

        let title = config == .messages ? "New Message" : "Search"
        configureNavigationBar(withTitle: title, prefersLargeTitles: true)
        if config == .messages {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        }
        UITextField.appearance().tintColor = .myBackgroundColor
    }
    func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.keyboardDismissMode = .interactive
    }
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsCancelButton = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user"
        navigationItem.searchController = searchController
        definesPresentationContext = false
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .darkGreen
            textField.backgroundColor = .white
        }
    }
    
    // MARK: - Selectors
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - TableView Controller DataSource & Delegate
extension SearchController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.user = user
        cell.selectionStyle = .none
        return cell
    }
    // TODO: Update the didSelect to reflect search vs newMessage
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]

        if config == .userSearch {
            let controller = ProfileController(user: user)
            navigationController?.pushViewController(controller, animated: true)
        }  else if config == .messages {
            delegate?.controller(self, wantsToStartChatWith: user)
        }
    }
}


// MARK: - Search Results Updating
extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredUsers = users.filter({ $0.username.contains(searchText) })
    }
}
