//
//  UserModel.swift
//  PChat
//
//  Created by Robin Ruf on 11.01.21.
//

import Foundation

class UserModel {
    
    var uid: String?
    var username: String?
    var email: String?
    var image: String?
    
    init(dictionary: [String: Any]) {
        uid = dictionary["uid"] as? String
        username = dictionary["username"] as? String
        email = dictionary["email"] as? String
        image = dictionary["profile_image"] as? String
    }
}
