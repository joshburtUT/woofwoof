//
//  SignupVC.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

class SignupController: UIViewController, Alertable {
    
    
    // MARK: - Properties
    private var profileImage: UIImage?
    private let addProfileButtonSize: CGFloat = 100
    private let addProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
    }()
    private lazy var fullnameContainerView: UIView = {
        let image = UIImage(systemName: "person")?.imageWithColor(color: .white)
        let view = Utilities().inputContainerView(withImage: image!, textField: fullnameTextField)
        return view
    }()
    private let fullnameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Full Name")
        tf.addTarget(self, action: #selector(handleFormValidation), for: .editingChanged)
        return tf
    }()
    private lazy var usernameContainerView: UIView = {
        let image = UIImage(systemName: "person")?.imageWithColor(color: .white)
        let view = Utilities().inputContainerView(withImage: image!, textField: usernameTextField)
        return view
    }()
    private let usernameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Username")
        tf.addTarget(self, action: #selector(handleFormValidation), for: .editingChanged)
        return tf
    }()
    private lazy var emailContainerView: UIView = {
        let image = UIImage(systemName: "envelope")?.imageWithColor(color: .white)
        let view = Utilities().inputContainerView(withImage: image!, textField: emailTextField)
        return view
    }()
    private let emailTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Email")
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(handleFormValidation), for: .editingChanged)
        return tf
    }()
    private lazy var passwordContainerView: UIView = {
        let image = UIImage(systemName: "lock")?.imageWithColor(color: .white)
        let view = Utilities().inputContainerView(withImage: image!, textField: passwordTextField)
        return view
    }()
    private let passwordTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Password")
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleFormValidation), for: .editingChanged)
        return tf
    }()
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.backgroundColor = UIColor(white: 0, alpha: 0.3)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return button
    }()
    private let alreadyHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton("Already have an account? ", " Sign In")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        hideKeyboard()
    }
    
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .darkGreen
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(addProfileButton)
        addProfileButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        addProfileButton.setDimensions(width: addProfileButtonSize, height: addProfileButtonSize)
        
        let stack = UIStackView(arrangedSubviews: [fullnameContainerView,
                                                   usernameContainerView,
                                                   emailContainerView,
                                                   passwordContainerView,
                                                   signupButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: addProfileButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 50, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                                        paddingLeft: 40, paddingBottom: 20, paddingRight: 40)

    }
    func configureImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    func saveUserCredentials(email: String, password: String) {
        // Set the Key to the user email
        let userDefaults = UserDefaults.standard
        userDefaults.set(email, forKey: KeychainConstants.kEmail)
        userDefaults.set(true, forKey: KeychainConstants.kBiometricEnabled)
        userDefaults.synchronize()
        
        let passwordItem = KeychainPasswordItem(service: KeychainConfig.serviceName, account: email, accessGroup: KeychainConfig.accessGroup)
        
        do {
            try passwordItem.savePassword(password)
            print("JOSH: Password saved to Keychain is \(password)")
        } catch let error {
            fatalError("JOSH: Error saving password to Keychain with - \(error.localizedDescription)")
        }

    }
    
    // MARK: - Selectors
    @objc func handleShowLogin() {
        _ = navigationController?.popViewController(animated: true)
    }
    @objc func handleSignup() {
        do {
            let email = try emailTextField.validatedText(validationType: ValidatorType.email)
            let password = try passwordTextField.validatedText(validationType: ValidatorType.password)
//            guard let password = passwordTextField.text else { return }
            guard let fullname = fullnameTextField.text else { return }
//            let fullname = try fullnameTextField.validatedText(validationType: ValidatorType.fullname)
            let username = try usernameTextField.validatedText(validationType: ValidatorType.username)

            
            // TODO: remove whitespaces & lines & symbols for username
//            guard let username = usernameTextField.text?.lowercased() else { return }
            let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .symbols).trimmingCharacters(in: .punctuationCharacters)
//
            guard let profileImage = self.profileImage else { return }
            
            let credentials = AuthCredentials(email: email, password: password, fullname: fullname, username: trimmedUsername, profileImage: profileImage)
            
            AuthService.signUserUp(withCredentials: credentials, onSuccess: {
                guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
                guard let tabController = window.rootViewController as? MainTabBarController else { return }
                tabController.authenticateUserAndConfigureUI()
                self.dismiss(animated: true, completion: nil)
                
                self.saveUserCredentials(email: email, password: password)
                print("JOSH: Saved User Credentials -- Email is \(email) & Password is \(password)")
                
            }) { (signupError) in
                self.showAlert(withTitle: "Error", andMessage: signupError!)
            }
        } catch (let error) {
            showAlert(withTitle: "Oops", andMessage: (error as! ValidationError).message)
        }

    }
    @objc func handleFormValidation() {
        guard fullnameTextField.hasText, usernameTextField.hasText, emailTextField.hasText, passwordTextField.hasText else {
            signupButton.isEnabled = false
            signupButton.backgroundColor = UIColor(white: 0, alpha: 0.3)
            return
        }
        signupButton.isEnabled = true
        signupButton.backgroundColor = UIColor(white: 1, alpha: 1)
    }
    @objc func handleSelectProfilePhoto() {
        configureImagePicker()
    }
}


// MARK: - ImagePicker Delegate
extension SignupController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // TODO: Validate that an image has been selected
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        self.profileImage = selectedImage
        addProfileButton.layer.cornerRadius = addProfileButtonSize / 2
        addProfileButton.layer.masksToBounds = true
        addProfileButton.layer.borderColor = UIColor.lightGray.cgColor
        addProfileButton.layer.borderWidth = 2
        addProfileButton.imageView?.contentMode = .scaleAspectFill
        addProfileButton.imageView?.clipsToBounds = true

        addProfileButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
}
