//
//  LoginVC.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, Alertable {
    
    // MARK: - Properties
    private let biometricAuth = BiometricAuth()
    
    private let logoImageSize: CGFloat = 150
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "logo")
        return iv
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
        let image = UIImage(systemName: "lock")?.imageWithColor(color: UIColor.white)
        let view = Utilities().inputContainerView(withImage: image!, textField: passwordTextField)
        return view
    }()
    private let passwordTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Password")
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleFormValidation), for: .editingChanged)
        return tf
    }()
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.backgroundColor = UIColor(white: 0, alpha: 0.3)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    private lazy var forgotPassword: UIButton = {
        let button = Utilities().attributedButton("Forgot your password? ", "Send a link")
        button.addTarget(self, action: #selector(handleSendPasswordReset), for: .touchUpInside)
        return button
    }()
    private lazy var biometricButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: ""), for: .normal)
        button.setDimensions(width: 60, height: 60)
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleLoginWithBiometrics), for: .touchUpInside)
        return button
    }()
    private lazy var dontHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton("Don't have an account? ", " Sign Up")
        button.addTarget(self, action: #selector(handleShowSignup), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        hideKeyboard()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureBiometricButton()
        checkBiometricAuthStatus()
    }
    
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = UIColor.darkGreen
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 50)
        logoImageView.setDimensions(width: logoImageSize, height: logoImageSize)
        
        let stackView = UIStackView(arrangedSubviews: [emailContainerView,
                                                       passwordContainerView,
                                                       loginButton,
                                                       forgotPassword])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                         paddingTop: 50, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(biometricButton)
        biometricButton.centerX(inView: view, topAnchor: stackView.bottomAnchor, paddingTop: 20)
//        biometricButton.setDimensions(width: 100, height: 100)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                                     paddingLeft: 40, paddingBottom: 20, paddingRight: 40)
    }
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    func configureBiometricButton() {
        biometricButton.isHidden = !biometricAuth.canEvaluatePolicy()
        
        switch biometricAuth.biometricType() {
        case .touchID:
            biometricButton.setImage(UIImage(named: "TouchIcon"), for: .normal)
        default:
            biometricButton.setImage(UIImage(named: "FaceIcon"), for: .normal)
        }
    }
    func checkBiometricAuthStatus() {
        let biometricEnabled = UserDefaults.standard.value(forKey: KeychainConstants.kBiometricEnabled) as? Bool
        
        if biometricEnabled != nil && biometricEnabled == true {
            biometricButton.isHidden = false
        } else {
            biometricButton.isHidden = true
        }
        
        if let email = UserDefaults.standard.value(forKey: KeychainConstants.kEmail) as? String {
            emailTextField.text = email
        }
    }
    func authenticateUserWith(email: String, password: String) {
        AuthService.logUserIn(withEmail: email, andPassword: password, onSuccess: {
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
            guard let tabController = window.rootViewController as? MainTabBarController else { return }
            tabController.authenticateUserAndConfigureUI()
            self.dismiss(animated: true, completion: nil)
        }) { (loginError) in
            self.showAlert(withTitle: "Error", andMessage: loginError!)
        }
    }
    
    // MARK: - Selectors
    @objc func handleLogin() {
        do {
            let email = try emailTextField.validatedText(validationType: ValidatorType.email)
            //let password = try passwordTextField.validatedText(validationType: ValidatorType.password)
            guard let password = passwordTextField.text else { return }
            authenticateUserWith(email: email, password: password)
            
        } catch (let error) {
            showAlert(withTitle: "Oops", andMessage: (error as! ValidationError).message)
        }
    }
    @objc func handleShowSignup() {
        let controller = SignupController()
        navigationController?.pushViewController(controller, animated: true)
    }
    @objc func handleFormValidation() {
        guard emailTextField.hasText, passwordTextField.hasText else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(white: 0, alpha: 0.3)
            return
        }
        loginButton.isEnabled = true
        loginButton.backgroundColor = UIColor(white: 1, alpha: 1)
    }
    @objc func handleSendPasswordReset() {
        if emailTextField.text!.isEmpty {
            showAlert(andMessage: "Please enter your email linked to this app")
            return
        }
        guard let email = emailTextField.text else { return }
        AuthService.sendPasswordReset(withEmail: email, onSuccess: {
            self.showAlert(andMessage: "A link has been sent to your email.")
        }) { (resetError) in
            self.showAlert(withTitle: "Oops", andMessage: resetError!)
        }
    }
    @objc func handleLoginWithBiometrics() {
        biometricAuth.authenticateUser { (message) in
            if let message = message {
                self.showAlert(andMessage: message)
            }
            if let email = UserDefaults.standard.value(forKey: KeychainConstants.kEmail) as? String {
                do {
                    let passwordItem = KeychainPasswordItem(service: KeychainConfig.serviceName, account: email, accessGroup: KeychainConfig.accessGroup)
                    let password = try passwordItem.readPassword()
                    self.authenticateUserWith(email: email, password: password)
                } catch let error {
                    print("JOSH: Failed to login with Biometrics - \(error.localizedDescription)")
                }
            }
        }
    }
}
