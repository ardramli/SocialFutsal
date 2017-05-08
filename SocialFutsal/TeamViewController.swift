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
    @IBOutlet weak var playerListTableView: UITableView!{
        didSet{
            playerListTableView.delegate = self
            playerListTableView.dataSource = self
            
            playerListTableView.register(PlayersListTableViewCell.cellNib, forCellReuseIdentifier: PlayersListTableViewCell.cellIdentifier)
        }
    }
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pieChartView: PieChartView!
    
    var ref: FIRDatabaseReference!
    var currentTeamID = ""
    
    var teamID : String?
    var uid : String?
    var players = [User]()
    var loadTeamMember = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        navigationItem.leftBarButtonItem?.title = ""
        //        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.hidesBackButton = true
        
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
        
        listenToFirebase()
        
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
        
        
        ref.child("teams").child(currentTeamID).observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            let dictionary = snapshot.value as? [String: Any]
            
            let currentTeamProfile = Team(withAnId: (self.currentTeamID), aUserID: (dictionary?["creatorID"])! as! String, aTeamLogo: (dictionary?["teamLogoUrl"])! as! String, aTeamName: (dictionary?["name"])! as! String, aTeamLocation: (dictionary?["location"])! as! String, withPlayers: (dictionary?["teammates"])!as! [String])
            
            // load screen name in nav bar
            self.navigationItem.title = currentTeamProfile.teamName
            
            // load the profile image
            self.teamLogoImageView.loadImageUsingCacheWithUrlString(urlString: currentTeamProfile.teamLogoUrl!)
            
            // load the user name
            self.teamNameLabel.text = currentTeamProfile.teamName
            
            //to load team member from myteamviewcontroller
            if self.loadTeamMember {
                self.players = []
                for playerID in currentTeamProfile.players {
                    self.observeTeammates(playerID: playerID)
                }
                
            }
            
        })
    }
    
    func observeTeammates(playerID : String){
        ref = FIRDatabase.database().reference()
        
        
        ref.child("users").child(playerID).observe(.value, with: { (snapshot2) in
            if let dictionary = snapshot2.value as? [String: Any] {
                let newPlayer = User(withAnId: playerID, anEmail: dictionary["email"]! as! String, aName: dictionary["name"]! as! String, aScreenName: dictionary["username"]! as! String, aDesc: dictionary["desc"]! as! String, aProfileImageURL: dictionary["profileImageUrl"]! as! String)
                self.players.append(newPlayer)
                
                DispatchQueue.main.async {
                    self.playerListTableView.reloadData()
                }
                
            }
        })
        
    }
    
}

extension TeamViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.players.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayersListTableViewCell.cellIdentifier) as? PlayersListTableViewCell
            else { return UITableViewCell()}
        
        let player = players[indexPath.row]
        cell.usernameLabel?.text = player.name
        
        if let profileimageUrl = player.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileimageUrl)
        }
        return cell
    }
    
}

