//
//  UserCell.swift
//  PChat
//
//  Created by Robin Ruf on 11.01.21.
//

import UIKit
import FirebaseDatabase
import SDWebImage
import FirebaseAuth

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet{
            
            let chatPartnerID: String?
            
            if message?.fromUserUID == Auth.auth().currentUser?.uid {
                chatPartnerID = message?.toUserUID
            } else {
                chatPartnerID = message?.fromUserUID
            }
            
            if let id = chatPartnerID {
                let ref = Database.database().reference().child("users").child(id)
                
                ref.observeSingleEvent(of: .value) { (data) in
                    if let dic = data.value as? [String : Any] {
                        self.textLabel?.text = dic["username"] as? String
                        
                        if let ChatprofileImage = dic["profile_image"] as? String {
                            let url = URL(string: ChatprofileImage)
                            self.profileImage.sd_setImage(with: url, completed: nil)
                        }
                    }
                }
                if let messageText = message?.message {
                    detailTextLabel?.text = messageText
                }
                
                if let seconds = message?.timeStamp {
                    let timeDate = Date(timeIntervalSince1970: Double(seconds))
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    timeLabel.text = dateFormatter.string(from: timeDate)
                }
            }
        }
    }
    
    // Profilbild
    let profileImage: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "default_profile"))
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // Zeitanzeige
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        //label.text = "err"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // Bestimmen, dass jede Zelle vom Style "Subtitle" sein soll, das heisst oben sieht man den Namen unten dran die Nachricht/email o.ä.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "userCell")
        
        // und jedesmal wenn eine Zeile erstellt wird, pack das Profilbild hinzu
        addSubview(profileImage)
        addSubview(timeLabel)
        
        // Jede einzelne Zeile richtig anordnen (Bild positionieren)
        profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 38).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
        
        // Damit die Label etc. neu positioniert werden.
        // awakeFromNib = Erwachen der Felder
        super.awakeFromNib()
    }
    
    // Den brauchen wir halt einfach - machen müssen wir damit jedoch nichts
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Die Subviews (dort wo Username & Nachricht/Email dann steht neu positionieren, da an der eigentlichen Stelle das Profilbild nun ist
    override func layoutSubviews() {
        super.layoutSubviews()
        // Textlabel wählen - bei dem Init->Style = .subtitle werden 2 Stück immer mitgeliefert (TextLabel (oben), detailtextlabel (untendran)
        textLabel?.frame = CGRect(x: 80, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 80, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override func awakeFromNib() {
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
