//
//  UsersListViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 04/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit
import Firebase

class UsersListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.register(UsersListTableViewCell.cellNib, forCellReuseIdentifier: UsersListTableViewCell.cellIdentifier)
        }
    }
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        fetchUser()
    }
    
    func handleCancel() {
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
        
        if let profileimageUrl = user.profileImageUrl {   
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileimageUrl)
        }

       
        return cell
    }
}