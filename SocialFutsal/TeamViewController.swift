//
//  TeamViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 03/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit
import Charts
import Firebase

class TeamViewController: UIViewController {
    @IBOutlet weak var playersListView: UIView!
    @IBOutlet weak var playerListTableView: UITableView!
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pieChartView: PieChartView!
    
    var ref: FIRDatabaseReference!
    var currentTeamID = ""
    
    var teamID : String?
    var uid : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pieChartView.isHidden = true
        playersListView.isHidden = false
        
        let stats = ["Games Played", "Wins" , "Losses"]
        let amount = [100,80,20]
        
        
        var pcDataEntries = [PieChartDataEntry]()
        for i in 0..<stats.count {
            let pcDataEntry = PieChartDataEntry(value: Double(amount[i]), label: stats[i])
            pcDataEntries.append(pcDataEntry)
        }
        let pcDataSet = PieChartDataSet(values: pcDataEntries, label: "Legend Information")
        pcDataSet.colors = [.blue,.red,.green,.black]
        pcDataSet.valueColors = [.yellow , .blue,.red,.green,.black]
        
        
        let pcData = PieChartData(dataSets: [pcDataSet])
        
        
        pieChartView.data = pcData
        pieChartView.centerText = "Team Name"
        pieChartView.chartDescription?.text = "Team Stats"
        
        ref = FIRDatabase.database().reference()
        ref.child("teams").observe(.childAdded, with: { (snapshot) in
            self.uid = snapshot.key
        })
        
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            pieChartView.isHidden = true
            playersListView.isHidden = false
        case 1:
            pieChartView.isHidden = false
            playersListView.isHidden = true
        default:
            break;
        }
    }
    
    func listenToFirebase(){
        
        if teamID == "" {
            teamID = (uid)!
        }
        
        ref.child("teams").child(teamID!).observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            let dictionary = snapshot.value as? [String: Any]
            
            let currentTeamProfile = Team(withAnId: (snapshot.key), aUserID: (dictionary?["creatorID"])! as! String, aTeamLogo: (dictionary?["teamLogoUrl"])! as! String, aTeamName: (dictionary?["name"])! as! String, aTeamLocation: (dictionary?["location"])! as! String, withPlayers: (dictionary?["teammates"])!as! [String])
            
            
            // load screen name in nav bar
            self.navigationItem.title = currentTeamProfile.teamName
            
            
            // load the profile image
            self.teamLogoImageView.loadImageUsingCacheWithUrlString(urlString: currentTeamProfile.teamLogoUrl!)
            
            
            // load the user name
            self.teamNameLabel.text = currentTeamProfile.teamName
            
            // load the user description
            //self.descTextView.text = currentTeamProfile.desc
            
            //self.wholeView.isHidden = false
            
        })
    }

    
    
}
