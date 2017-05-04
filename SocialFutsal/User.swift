//
//  User.swift
//  SocialFutsal
//
//  Created by ardMac on 02/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import Foundation

class User {
    
    static let currentUser = User()
    
    var id: String?
    var email : String?
    var name : String?
    var username : String?
    var desc : String?
    var profileImageUrl : String?
    
    init() {
        id = ""
        email = ""
        name = ""
        username = ""
        desc = ""
        profileImageUrl = ""
    }
    
    init(withAnId : String, anEmail : String, aName : String, aScreenName : String, aDesc : String, aProfileImageURL : String) {
        id = withAnId
        email = anEmail
        name = aName
        username = aScreenName
        desc = aDesc
        profileImageUrl = aProfileImageURL
    }
    
    init(dictionary: [String: AnyObject]) {
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        username = "Anonymous"
        email = dictionary["email"] as? String
        desc = "I love Futsal"
        profileImageUrl = dictionary["profileImageUrl"] as? String
    }
    
    func updateUser(withAnId : String, anEmail : String, aName : String, aScreenName : String, aDesc : String, aProfileImageURL : String) {
        id = withAnId
        email = anEmail
        name = aName
        username = aScreenName
        desc = aDesc
        profileImageUrl = aProfileImageURL
    }
    
    
}
