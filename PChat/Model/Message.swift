//
//  Message.swift
//  PChat
//
//  Created by Robin Ruf on 19.01.21.
//

import Foundation
import FirebaseAuth

class Message {
    
    var fromUserUID : String?
    var toUserUID : String?
    var message : String?
    var timeStamp : Int?
    
    init(dictionary : [String : Any]) {
        self.fromUserUID = dictionary["fromUserUID"] as? String
        self.toUserUID = dictionary["toUserUID"] as? String
        self.message = dictionary["messages"] as? String
        self.timeStamp = dictionary["timestamp"] as? Int
    }
    
    func chatPartnerID() -> String? {
        if fromUserUID == Auth.auth().currentUser?.uid {
            return toUserUID
        } else {
            return fromUserUID
        }
    }
    
}
