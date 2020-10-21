//
//  UploadPostVC.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit
import ActiveLabel

class UploadController: UIViewController, Alertable {
    
    // MARK: - Properties
    private let user: UserModel
    private let config: UploadPostConfiguration
    private lazy var viewModel = UploadViewModel(config: config) // set as lazy because the config has not been setup yet
    
    private let maxNumberOfCharacters = 200
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .darkGreen
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(handleUpload), for: .touchUpInside)
        return button
    }()
    private let profileImageView: CircularImageView = {
        let iv = CircularImageView(width: 48)
        return iv
    }()
    // Need to set it as a lazy var because we have given it a property based on the view size...needs time to set
    private lazy var replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        label.font = UIFont.systemFont(ofSize: 14)
        label.mentionColor = .systemGreen
        label.textColor = .myTitleLabelColor
        return label
    }()
    private let captionTextView = CaptionTextView()
    
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .lightGray
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Lifecycle
    init(user: UserModel, config: UploadPostConfiguration) {
        self.user = user
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captionTextView.delegate = self
        
        configureUI()
        configureMentionHandler()
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }

    // MARK: - API
    func uploadPost() {
        guard let caption = captionTextView.text else { return }
        PostService.uploadPost(caption: caption, type: config) { (err, ref) in
            if err != nil {
                self.showAlert(withTitle: "Oops", andMessage: "Were were unable to upload you post because \(err!.localizedDescription)")
                return
            }
            // check if the case matches one from config (because its has an associatedType use "=" rather than conditional check "=="
            if case .reply(let post) = self.config {
                NotificationService.uploadNotification(toUser: post.user, type: .reply, postId: post.postId)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    func uploadMentionNotification(forCaption caption: String, postId: String?) {
        guard caption.contains("@") else { return }
        let words = caption.components(separatedBy: .whitespacesAndNewlines)
        words.forEach { (word) in
            guard word.hasPrefix("@") else { return }
            var username = word.trimmingCharacters(in: .symbols)
            username = username.trimmingCharacters(in: .punctuationCharacters)
            
            UserService.fetchUser(withUsername: username) { (mentionedUser) in
                NotificationService.uploadNotification(toUser: mentionedUser, type: .mention, postId: postId)
            }
        }
    }

    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .myBackgroundColor
        configureNavBar()
        
        let profileCaptionStack = UIStackView(arrangedSubviews: [profileImageView, captionTextView])
        profileCaptionStack.spacing = 12
        profileCaptionStack.alignment = .leading // allows for the both elements to display their correct individual heights even when in a stack
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, profileCaptionStack])
        stack.axis = .vertical
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor,
                                paddingTop: 16, paddingLeft: 16, paddingRight: 16)
        profileImageView.sd_setImage(with: user.profileImageUrl)
        
        view.addSubview(characterCountLabel)
        characterCountLabel.anchor(top: profileCaptionStack.bottomAnchor, right: profileCaptionStack.rightAnchor,
                                   paddingTop: 4, paddingRight: 16, width: 100)
        
        actionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        captionTextView.placeholderLabel.text = viewModel.placeholderText
        
        replyLabel.isHidden = !viewModel.shouldShowReplyLabel
        guard let replyText = viewModel.replyText else { return }
        replyLabel.text = replyText
    }
    func configureNavBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .darkGreen
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
    func configureMentionHandler() {
        replyLabel.handleMentionTap { (mention) in
            // TODO: segue to user profile
            print("JOSH: Mention Tapped")
        }
    }
    

    // MARK: - Selectors
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    @objc func handleUpload() {
        uploadPost()
    }
    @objc func textViewDidChange(textView: CaptionTextView) {
        guard let text = captionTextView.text else { return }
        characterCountLabel.text = "\(text.count)/200"
    }
}


// MARK: - TextField Delegate - Sets the upper limit for character count in TextField
extension UploadController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 200
    }
}

