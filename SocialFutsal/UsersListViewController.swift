//
//  UsersListViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 04/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit
import Firebase
protocol UserListDelegate {
    func inviteUsers (_ players: [User])
}

class UsersListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.register(UsersListTableViewCell.cellNib, forCellReuseIdentifier: UsersListTableViewCell.cellIdentifier)
        }
    }
    var users = [User]()
    var players = [User]() //["Ard","max","nick","kim","hey"]
    var newTeamID : String = ""
    var delegate : UserListDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        fetchUser()
    }
    
    func handleCancel() {
        navigationController?.popViewController(animated: true)
        
    }
    
    func handleDone() {
        
//        if delegate != nil {
//            if let _players = players {
//                delegate?.passUser(players)
//            }
//        }
//        
        
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        guard let controller = storyboard .instantiateViewController(withIdentifier: "CreateTeamViewController") as?
//            CreateTeamViewController else { return }
//        controller.players = players
        delegate?.inviteUsers(players)
        navigationController?.popViewController(animated: true)
    }
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                let user = User()
                user.id = snapshot.key
                
                let currentProfileUser = User(withAnId: (snapshot.key), anEmail: (dictionary["email"])! as! String, aName: (dictionary["name"])! as! String, aScreenName: (dictionary["username"])! as! String, aDesc: (dictionary["desc"])! as! String, aProfileImageURL: (dictionary["profileImageUrl"])! as! String)
                
                
                
                self.users.append(currentProfileUser)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        }, withCancel: nil)
    }

}


extension UsersListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UsersListTableViewCell.cellIdentifier) as? UsersListTableViewCell
            else { return UITableViewCell()}
        
        let user = users[indexPath.row]
        cell.usernameLabel?.text = user.name
        cell.locationLabel?.text = user.email
        cell.inviteButton.tag = indexPath.row
        cell.inviteButton.addTarget(self, action: #selector(inviteButtonTapped(sender:)), for: .touchUpInside)
        
        if let profileimageUrl = user.profileImageUrl {   
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileimageUrl)
        }
        return cell
    }
    
    
    func inviteButtonTapped(sender: UIButton){
        
        let buttonRow = sender.tag
        let invitedUser = users[buttonRow]
        self.players.append(invitedUser)
        
//        self.players.append(invitedUser)
//        
//        print(self.players)
    
    }
    
    
    
}














