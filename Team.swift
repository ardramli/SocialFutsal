//
//  Team.swift
//  SocialFutsal
//
//  Created by ardMac on 03/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import Foundation

class Team {
    var id: String?
    var userId : String?
    var teamLogoUrl : String?
    var teamName : String?
    var teamLocation : String?
    
    init( ) {
        id = ""
        userId = ""
        teamLogoUrl = ""
        teamName = ""
        teamLocation = ""
    }
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.userId = dictionary["userId"] as? String
        self.teamLogoUrl = dictionary["teamLogoUrl"] as? String
        self.teamLocation = dictionary["teamLocation"] as? String
        self.teamName = dictionary["teamName"] as? String
    }
    
    init(withAnId : String, aUserID : String, aTeamLogo : String, aTeamName : String, aTeamLocation : String){
        id = withAnId
        userId = aUserID
        teamLogoUrl = aTeamLogo
        teamName = aTeamName
        teamLocation = aTeamLocation
    }
}
