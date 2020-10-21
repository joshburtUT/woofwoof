//
//  ChatVC.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ChatCell"

class ChatController: UICollectionViewController, Alertable {
    
    // MARK: - Properties
    var fromCurrentUser = false
    
    private let user: UserModel
    private var messages = [Message]()
    
    private lazy var customInputView: CustomInputAccessoryView = {
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        iv.delegate = self
        return iv
    }()

    // MARK: - Lifecycle
    init(user: UserModel) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        // hides tabBar when this controller is loaded
        hidesBottomBarWhenPushed = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchMessages()
    }
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: - API
    func fetchMessages() {
        MessageService.fetchMessages(withChatPartner: user.uid) { (messages) in
            self.messages = messages
            self.collectionView.reloadData()
        }
    }


    // MARK: - Helpers
    func configureUI() {
        configureNavigationBar(withTitle: user.fullname, prefersLargeTitles: true)
        configureCollectionView()
    }
    func configureCollectionView() {
        collectionView.backgroundColor = .myBackgroundColor
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
    

    // MARK: - Selectors




}


// MARK: - CollectionView DataSource & Delegate
extension ChatController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.message = messages[indexPath.row]
        cell.message?.user = user
        return cell
    }
}


// MARK: - CollectionView Delegate Flow Layout
extension ChatController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let estimatedSizeCell = MessageCell(frame: frame)
        estimatedSizeCell.message = messages[indexPath.row]
        estimatedSizeCell.layoutIfNeeded()

        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
}


// MARK: - Custom Input Accessory View Delegate
extension ChatController: CustomInputAccessoryViewDelegate {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String) {
        MessageService.uploadMessage(message, toUser: user) { (err, ref) in
            if err != nil {
                self.showAlert(withTitle: "Oops", andMessage: "We were unable to upload your message because \(err!.localizedDescription)")
                return
            }
            inputView.clearMessageText()
        }
    }
}
