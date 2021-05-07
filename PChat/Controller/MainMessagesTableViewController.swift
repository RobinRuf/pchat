//
//  MainMessagesTableViewController.swift
//  PChat
//
//  Created by Robin Ruf on 12.01.21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class MainMessagesTableViewController: UITableViewController {
    
    let cellID = "UserCellID"
    
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 90
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearch))
        
        // Lade aktuellen User
        fetchLoggedUser()
        
        // Lade Nachrichten
        //observeMessages()
        
        // Lade Nachrichten des einzelnen Users
        observeUserMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchLoggedUser()
    }
    
    @objc func handleLogout() {
        // User ausloggen
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        
        // Dann noch das Fenster wo die Chats sind "dismissen/schlissen", damit wir wieder beim Einlogg-Fenster sind
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Setup Navigation Bar
    func fetchLoggedUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Daten des eingeloggten Nutzers downloaden und in ein Dictionary speichern (email, username, bild)
        // as? [String: Any] = probier die Daten in das Dictionary zu speichern, der Key ist dabei immer ein String und der Wert/Value kann alles sein
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (data) in
            if let dic = data.value as? [String: Any] {
                // dann wenn das geklappt hat, mache ich ein Object der Klasse UserModel und übergebe diesem die downgeloadeten Daten, damit der die Daten in die Variablen abspeichert und ich die weiterverwenden kann
                let user = UserModel(dictionary: dic)
                self.setupNavigationBarWithUser(user: user)
            }
        }
    }
    
    var messages = [Message]()
    var messageDictionary = [String : Message]()
    
    // MARK: - Download Messages
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded) { (data) in
            let messageID = data.key
            
            let messageRef = Database.database().reference().child("messages").child(messageID)
            messageRef.observeSingleEvent(of: .value) { (data) in
                if let dic = data.value as? [String : Any] {
                    let message = Message(dictionary: dic)
                    
                    if let chatPartnerID = message.chatPartnerID() {
                        self.messageDictionary[chatPartnerID] = message
                        self.messages = Array(self.messageDictionary.values)
                    }
                    
                    self.timer?.invalidate()
                    
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTableData), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    @objc func handleReloadTableData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // Anzeigen der Daten des eingeloggten Nutzers
    func setupNavigationBarWithUser(user: UserModel) {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

        // Den containerView fügen wir in den titleView hinzu damit wir da drin das Auto-Layout machen können
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)

        // Profile Image View erstellen
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        // clipToBounds sorgt dafür, dass das Bild in dem runden Rahmen bleibt und nicht drüber rausschaut
        profileImageView.clipsToBounds = true

        // Bild runterladen
        if let url = user.image {
            // Wenn die URL gefunden wurde als String, dann verwandel die in eine URL und speicher die in dieser Konstanten ab
            let profileURL = URL(string: url)
            // Dem ProfileImageView das Image übergeben
            profileImageView.sd_setImage(with: profileURL, completed: nil)
        }

        // Label erstellen
        let nameLabel = UILabel()
        nameLabel.text = user.username
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // Das ProfileImageView in den ContainerView einbauen
        containerView.addSubview(profileImageView)
        // nameLabel dem containerView hinzufügen
        containerView.addSubview(nameLabel)

        // Layout der Elemente
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    
        // Dem NavigationView hinzufügen
        navigationItem.titleView = titleView
        
    }
   
    
    @objc func handleSearch() {
        let messageTVC = MessagesTableViewController()
        messageTVC.messageController = self
        let navController = UINavigationController(rootViewController: messageTVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    func showChatControllerFor(user: UserModel) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    // MARK: - table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerID = message.chatPartnerID() else { return }
        
        // Nachrichten von Chatpartner downloaden
        let chatPartnerRef = Database.database().reference().child("users").child(chatPartnerID)
        
        chatPartnerRef.observeSingleEvent(of: .value) { (data) in
            guard let dic = data.value as? [String : Any] else { return }
            
            let user = UserModel.init(dictionary: dic)
            user.uid = chatPartnerID
            
            self.showChatControllerFor(user: user)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell

        let message = messages[indexPath.row]
        cell.message = message

        return cell
    }
}
