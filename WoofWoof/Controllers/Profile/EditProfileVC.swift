//
//  EditProfileVC.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

private let reuseIdentifier = "EditProfileCell"

protocol EditProfileControllerDelegate: class {
    func controller(_ controller: EditProfileController, wantsToUpdate user: UserModel)
    func handleLogout()
}

class EditProfileController: UITableViewController {
    
    
    // MARK: - Properties
    weak var delegate: EditProfileControllerDelegate?
    
    private var user: UserModel
    private lazy var headerView = EditProfileHeader(user: user)
    private let footerView = EditProfileFooter()
    
    private let imagePicker = UIImagePickerController()
    
    private var selectedImage: UIImage? {
        didSet { headerView.profileImageView.image = selectedImage }
    }
    
    private var userInfoChanged = false
    private var imageChanged: Bool {
        return selectedImage != nil
    }

    // MARK: - Lifecycle
    init(user: UserModel) {
        self.user = user
        super.init(style: .plain)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - API
    func updateUserData() {
        if imageChanged && !userInfoChanged {
            updateProfileImage()
        }
        if userInfoChanged && !imageChanged {
            UserService.updateUserData(user: user) { (err, ref) in
                self.delegate?.controller(self, wantsToUpdate: self.user)
            }
        }
        if userInfoChanged && imageChanged {
            UserService.updateUserData(user: user) { (err, ref) in
                self.updateProfileImage()
            }
        }
    }


    // MARK: - Helpers
    func configureUI() {
        configureNavigationBar()
        configureTableView()
        configureImagePicker()
    }
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .darkGreen
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.title = "Edit Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
    }
    func configureTableView() {
        tableView.backgroundColor = .myBackgroundColor
        
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        headerView.delegate = self

        tableView.tableFooterView = footerView
        
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        footerView.delegate = self
        
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    // FIXME: Need to figure out how to display the updated image...Lecture 101 ~ 8mins
    func updateProfileImage() {
        guard let image = selectedImage else { return }
        UserService.updateProfileImage(image: image) { (profileImageUrl) in
            let imageUrl = URL(fileURLWithPath: profileImageUrl)
            self.user.profileImageUrl = imageUrl
            self.delegate?.controller(self, wantsToUpdate: self.user)
        }
    }
    
    
    // MARK: - Selectors
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    @objc func handleDone() {
        view.endEditing(true)
        guard imageChanged || userInfoChanged else { return }
        updateUserData()
    }
}



// MARK: - TableView Data Source
extension EditProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EditProfileCell
        cell.delegate = self
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return UITableViewCell() }
        cell.viewModel = EditProfileViewModel(user: user, option: option)
        return cell
    }
}

// MARK: - TableView Delegate
extension EditProfileController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return 0 }
        return option == .bio ? 100 : 60
    }
}


// MARK: - Edit Profile Header Delegate
extension EditProfileController: EditProfileHeaderDelegate {
    func handleChangeProfilePhoto() {
        present(imagePicker, animated: true, completion: nil)
    }
}


// MARK: - ImagePicker Delegate
extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        self.selectedImage = image
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Edit Profile Cell Delegate
extension EditProfileController: EditProfileCellDelegate {
    func updateUserInfo(_ cell: EditProfileCell) {
        guard let viewModel = cell.viewModel else { return }
        
        userInfoChanged = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        switch viewModel.option {
        case .fullname:
            guard let fullname = cell.infoTextField.text else { return }
            user.fullname = fullname
        case .username:
            guard let username = cell.infoTextField.text else { return }
            user.username = username
        case .bio:
            // Don't need to unwrap bc it is optional
            user.bio = cell.bioTextView.text
        }
    }
}


extension EditProfileController: EditProfileFooterDelegate {
    // Want the user to be presented a different screen when logging back in, instead of the logout/settings. Need to chain delegations
    func handleLogout() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { (_) in
            // Dismiss the Alert, then in the completion, logout the user
            self.dismiss(animated: true) {
                self.delegate?.handleLogout()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
