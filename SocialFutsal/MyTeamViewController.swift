//
//  MyTeamViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 04/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit
import Firebase

class MyTeamViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            
            tableView.register(PlayersListTableViewCell.cellNib, forCellReuseIdentifier: PlayersListTableViewCell.cellIdentifier)
        }
    }
    
    var ref: FIRDatabaseReference!
    var teams = [Team]()
    var uid : String?
    var players = [User]()
    var yourArray : [String] = []
    var teamsappended = false

    override func viewDidLoad() {
        super.viewDidLoad()
        observeTeams()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let controller = storyboard .instantiateViewController(withIdentifier: "CreateTeamViewController") as?
            CreateTeamViewController else { return }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func observeTeams(){
        
        ref = FIRDatabase.database().reference()
        
        ref.child("teams").observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            
            if let dictionary = snapshot.value as? [String:Any]{
                let teams = Team(withAnId: (snapshot.key), aUserID: (dictionary["creatorID"])! as! String, aTeamLogo: (dictionary["teamLogoUrl"])! as! String, aTeamName: (dictionary["name"])! as! String, aTeamLocation: (dictionary["location"])! as! String, withPlayers: (dictionary["teammates"])!as! [String])
                self.teams.append(teams)
                
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    func observeTeammates(id : String){
        ref = FIRDatabase.database().reference()
        
        ref.child("teams").child("\(id)").child("teammates").observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            
            if let userId = snapshot.value as? String{
                self.yourArray.append(userId)
                for value in self.yourArray {
                let playerID = value
                    
                self.ref.child("users").child(playerID).observe(.value, with: { (snapshot2) in
                    if let dictionary = snapshot2.value as? [String: Any] {
                        let newPlayer = User(withAnId: playerID, anEmail: dictionary["email"]! as! String, aName: dictionary["name"]! as! String, aScreenName: dictionary["username"]! as! String, aDesc: dictionary["desc"]! as! String, aProfileImageURL: dictionary["profileImageUrl"]! as! String)
                        self.players.append(newPlayer)
                        self.teamsappended = true
                        }
                    })
                    
                }
            }
        })
    }
    


}


extension MyTeamViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teams.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayersListTableViewCell.cellIdentifier) as? PlayersListTableViewCell
            else { return UITableViewCell()}
        
        let team = teams[indexPath.row]
        cell.usernameLabel.text = team.teamName
        
        if let logoImageUrl = team.teamLogoUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: logoImageUrl)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let goToViewController = self.storyboard?.instantiateViewController(withIdentifier: "TeamViewController") as? TeamViewController {
            goToViewController.currentTeamID = self.teams[indexPath.row].id!
            //goToViewController.players = players
            goToViewController.loadTeamMember = true
            observeTeammates(id: self.teams[indexPath.row].id!)
            //if teamsappended {
                self.navigationController?.pushViewController(goToViewController, animated: true)
            //}
        }
    }
}


