//
//  CreateTeamViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 04/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit
import Firebase

class CreateTeamViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var playerListTableView: UITableView!{
        didSet{
            playerListTableView.delegate = self
            playerListTableView.dataSource = self
            
            playerListTableView.register(PlayersListTableViewCell.cellNib, forCellReuseIdentifier: PlayersListTableViewCell.cellIdentifier)
        }
    }
    
    var teamID : String = ""
//    var playerss : [User] = []
    var players = [User]()//["Ard","max","nick","kim","hey"]

    var ref: FIRDatabaseReference!
    
    var currentUser = User.currentUser
    
    var profileUserID = ""
    var userUid : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleCreateTeam))
        playerListTableView.reloadData()
        
        userUid = FIRAuth.auth()?.currentUser?.uid
        
        ref = FIRDatabase.database().reference()
        
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playerListTableView.reloadData()
    }
    
    

    @IBAction func changeLogoButtonTapped(_ sender: Any) {
        handleSelectorProfileImageView()
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        if let userListVC = storyboard?.instantiateViewController(withIdentifier: "UsersListViewController") as? UsersListViewController {
            //userListVC.players = players
            userListVC.delegate = self
            navigationController?.pushViewController(userListVC, animated: true)
        }
    }
    

    
    func handleCreateTeam(){
        guard let name = teamNameTextField.text, let location = locationTextField.text
                    else {
                    return
                }
                if profileUserID == "" {
                    profileUserID = (userUid)!
                }
        
                let imageName = NSUUID().uuidString
                let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
        
                let teamRef = ref.childByAutoId()
                self.teamID = teamRef.key
        
                if let teamLogo = self.imageView.image, let uploadData = UIImageJPEGRepresentation(teamLogo, 0.1) {
                    storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
        
                        if error != nil {
                            print(error!)
                            return
                        }
                        if let teamLogoUrl = metadata?.downloadURL()?.absoluteString{
                            //to get only the name of players
                            let nameArray = self.players.map({ (player) -> String in
                                player.name ?? ""
                            })
                            
                            let values = ["name" : name, "location" : location, "teamLogoUrl" : teamLogoUrl, "creatorID" : self.userUid!, "teammates" : nameArray] as [String : Any]
                            self.registerUserIntoDatabaseWithUID(teamUid: self.teamID, values: values as [String : AnyObject])
                        }
                    })
                }
            dismiss(animated: true, completion: nil)
        //go to team VC
        if let teamProfileVC = storyboard?.instantiateViewController(withIdentifier: "TeamViewController") as? TeamViewController {
            teamProfileVC.currentTeamID = self.teamID
            navigationController?.pushViewController(teamProfileVC, animated: true)
        }
            }
        
            func registerUserIntoDatabaseWithUID(teamUid : String, values: [String: Any]) {
                let teamReference = ref.child("teams").child(teamUid)
                teamReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
                    if err != nil {
                        print(err!)
                        return
                    }
                })
        
    }
}

extension CreateTeamViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectorProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            imageView.image = selectedImage
            imageView.layer.cornerRadius = 99
            imageView.layer.masksToBounds = true
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}

extension CreateTeamViewController: UITableViewDelegate, UITableViewDataSource{
    
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

extension CreateTeamViewController: UserListDelegate {
    func inviteUsers(_ players: [User]) {
        self.players = players
    }
}



