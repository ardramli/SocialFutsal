//
//  Games.swift
//  SocialFutsal
//
//  Created by ardMac on 09/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import Foundation

class Games{
    var id : String?
    var hostID : String?
    var location : String?
    var time : String?
    var duration : String?
    var gameType : String?
    var price : String?
    var players : [User]?
    var teams : [Team]?
    
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.hostID = dictionary["hostID"] as? String
        self.location = dictionary["location"] as? String
        self.time = dictionary["time"] as? String
        self.duration = dictionary["duration"] as? String
        self.gameType = dictionary["gameType"] as? String
        self.price = dictionary["price"] as? String
        self.players = (dictionary["players"] as? [User])!
        self.teams = (dictionary["teams"] as? [Team])!
    }
    
    init(withAnId: String, withHost: String, aLocation: String, aTime: String, aDuration: String, aGameType: String,withPrice : String, withTeams: [Team]){
        id = withAnId
        hostID = withHost
        location = aLocation
        time = aTime
        duration = aDuration
        gameType = aGameType
        price = withPrice
        teams = withTeams
    }

}

