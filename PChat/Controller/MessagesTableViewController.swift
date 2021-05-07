//
//  MessagesTableViewController.swift
//  PChat
//
//  Created by Robin Ruf on 11.01.21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class MessagesTableViewController: UITableViewController {
    
    // Zeilen-Identifizierer (Identifier), damit wir mir der Zelle arbeiten können (Wie im Storyboard, wenn wir der Prototype-Cell einen Identifier geben)
    let cellId = "userCell"
    
    var users = [UserModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Logout Button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBackToChats))
        
        // Tabellenzeile zuweisen, dass wir eine eigene Klasse zum erstellen der Zeilen verwenden und den Identifier
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
        
        tableView.rowHeight = 90
    }
    
    @objc func handleBackToChats() {
        // Dismiss = Schmeisse/beende dieses Fenster und zeige somit das vorherige Fenster wieder an.
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUser() {
        // observed (observiert/beobachtet) die Datenbank und sobald ein neuer User dazukommt (.childAdded) wird dies ausgeführt
        Database.database().reference().child("users").observe(.childAdded) { (data) in
            // "data" sind die Daten, die wir zurückbekommen (also der neue User)
            // Das jedoch als Optional, also Optional Binding
            // Und falls da was drin ist, schau mal, ob du das in ein [String: Any] - Dictionary verwandeln kannst, da wir das in der Klasse UserModel verwenden wollen
            if let dic = data.value as? [String: Any] {
                // Wenn das geklappt hat, erstellen wir einen User mit dem Init der Klasse UserModel und erhalten somit die Daten
                let user = UserModel(dictionary: dic)
                // und dann fügen wir dies noch unserer Tabelle hinzu
                
                // Filtern, dass der User der eingeloggt ist da nicht angezeigt wird
                if user.uid != Auth.auth().currentUser?.uid {
                    self.users.append(user)
                }
                // Tabelle aktuallisieren - wegen der Performance, asynchron zum Rest
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    var messageController: MainMessagesTableViewController?
    
    // MARK: - Table view Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Wenn der Nutzer auf eine gewisse Zeile tippt, dann muss das Fenster sich schliessen, bevor wir das Chat-Fenster öffnen
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            guard let messageTVC = self.messageController else { return }
            messageTVC.showChatControllerFor(user: user)
    }
    }

    // MARK: - Table view data source

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }

    
    
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell

        let userObject = users[indexPath.row]
        cell.textLabel?.text = userObject.username
        cell.detailTextLabel?.text = userObject.email
        
        // Profilbild laden
        
        // Ist die URL vorhanden?
        if let url = userObject.image {
            // wenn die URL vorhanden ist, dann die URL downloaden
            let profileURL = URL(string: url)
            // Bild dem profileImageView hinzufügen
            cell.profileImage.sd_setImage(with: profileURL, completed: nil)
        }

        return cell
    }

    
}
