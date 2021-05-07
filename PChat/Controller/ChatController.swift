//
//  ChatController.swift
//  PChat
//
//  Created by Robin Ruf on 12.01.21.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChatController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellID = "messageCellID"
    
    lazy var inputTextField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Nachricht eingeben..."
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.delegate = self
        textfield.backgroundColor = UIColor.white
        
        return textfield
    }()
    
    var user: UserModel? {
        didSet {
            navigationItem.title = user?.username
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    // MARK: - Load Messages
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid)
        userMessageRef.observe(.childAdded) { (data) in
            let messageID = data.key
            let messageRef = Database.database().reference().child("messages").child(messageID)
            
            messageRef.observeSingleEvent(of: .value) { (data) in
                guard let dic = data.value as? [String : Any] else { return }
                
                let message = Message(dictionary: dic)
                
                if message.chatPartnerID() == self.user?.uid {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor.white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.alwaysBounceVertical = true
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 40, right: 0)
        
        setupInputComponents()
        setupKeyboardObserve()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyboardObserve() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyBoardWillShow(notification: NSNotification) {
        
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        let keyboardDurationTime = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        
        UIView.animate(withDuration: keyboardDurationTime!) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func handleKeyBoardWillHide(notification: NSNotification) {
        
        let keyboardDurationTime = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: keyboardDurationTime!) {
            self.view.layoutIfNeeded()
        }
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Das ContainerView in das normale View einfügen
        view.addSubview(containerView)
        
        // containerView ganz unten in der vollen Breite an das View anpassen
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // (type: .system --> Dann ist die Textfarbe im Button blau, damit man es sieht. (Automatisch)
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleSendButton), for: .touchDown)
        
        button.setTitle("send", for: .normal)
        button.backgroundColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(button)
        
        button.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        button.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: button.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLine = UIView()
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = UIColor.black
        
        containerView.addSubview(separatorLine)
        
        separatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: 0.2).isActive = true
    }
    
    // Definiert, was passiert, sobald der User auf "Send" klickt
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Nachricht zur Datenbank schicken
        handleSendButton()
        return true
    }
    
    @objc func handleSendButton() {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        // Von welchem Nutzer kommt die Nachricht
        guard let fromUserUID = Auth.auth().currentUser?.uid else { return }
        
        // An welchen Nutzer geht die Nachricht
        guard let toUserUID = user?.uid else { return }
        
        // Zeitpunkt der Nachricht
        let timeStamp = Int(Date().timeIntervalSince1970)
        
        guard let text = inputTextField.text else { return }
        
        let dic : [String : Any] = ["messages" : text, "fromUserUID" : fromUserUID, "timestamp" : timeStamp, "toUserUID" : toUserUID]
        //childRef.updateChildValues(dic)
        
        childRef.updateChildValues(dic) { (error, data) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let messageID = childRef.key else { return }
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromUserUID)
            
            let dic = [messageID : 1]
            userMessageRef.updateChildValues(dic)
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toUserUID)
            recipientUserMessagesRef.updateChildValues(dic)
            self.inputTextField.text = ""
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].message {
            let size = estimateFrameForText(text: text)
            height = size.height + 20
        }
        
        let size = CGSize(width: view.frame.width, height: height)
        return size
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
    }
    
    // MARK: - CollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as!  ChatMessageCell
        
        let message = messages[indexPath.item]
        
        cell.textView.text = message.message
        
        setupCell(cell, message: message)
        
        cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(text: message.message!).width + 32
        
        return cell
    }
    
    func setupCell(_ cell: ChatMessageCell, message: Message) {
        
        if let profileImageURL = user?.image {
            let url = URL(string: profileImageURL)
            cell.profileImageView.sd_setImage(with: url, completed: nil)
        }
        
        if message.fromUserUID == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.greenColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = UIColor(red: 70 / 255, green: 130 / 255, blue: 180 / 255, alpha: 0.8)
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
    }
    
    
}
