//
//  ProfileViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 02/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!{
        didSet{
            descTextView.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var teamsView: UIView!
    @IBOutlet weak var statisticsView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var teamsCollectionView: UICollectionView!{
        didSet{
            teamsCollectionView.delegate = self
            teamsCollectionView.dataSource = self
        }
    }

    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            teamsView.isHidden = true
            statisticsView.isHidden = false
        case 1:
            teamsView.isHidden = false
            statisticsView.isHidden = true
        default:
            break;
        }
    }
    
    var ref: FIRDatabaseReference!
    
    var currentUser = User.currentUser
    
    var profileUserID = ""
    var uid : String?
    var isFollowed = false
    var teamList : [Team] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uid = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        listenToFirebase()
        
        teamsView.isHidden = true
        statisticsView.isHidden = false
        
        // make the profile picture have a round radius
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
        // change the border color of button
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = 5
        followButton.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        
        // check if user profile is the same as current user
        // if same button text = "Edit Profile"
        // if not button text = "Follow"
        print("current user id: \(uid!)")
        print("profile user id: \(profileUserID)")
        if self.profileUserID != self.uid! {
            self.followButton.addTarget(self, action: #selector(self.followUser), for: .touchUpInside)
        } else {
            self.followButton.setTitle("Edit Profile", for: .normal)
            self.followButton.addTarget(self, action: #selector(self.editProfile), for: .touchUpInside)
        }

    }
    
    
    func listenToFirebase(){
        
        if profileUserID == "" {
            profileUserID = (uid)!
        }
        
        ref.child("users").child(profileUserID).observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            let dictionary = snapshot.value as? [String: Any]
            
            let currentProfileUser = User(withAnId: (snapshot.key), anEmail: (dictionary?["email"])! as! String, aName: (dictionary?["name"])! as! String, aScreenName: (dictionary?["username"])! as! String, aDesc: (dictionary?["desc"])! as! String, aProfileImageURL: (dictionary?["profileImageUrl"])! as! String)
            
            self.ref.child("users").child(self.uid!).child("following").child(self.profileUserID).observe(.value, with: { (instance) in
                print(instance)
                
                if instance.exists() {
                    self.isFollowed = true
                    self.followButton.setTitle("Following", for: .normal)
                }
                
            })
            
            // load screen name in nav bar
            self.navigationItem.title = currentProfileUser.username
            
            
            // load the profile image
            self.profileImageView.loadImageUsingCacheWithUrlString(urlString: currentProfileUser.profileImageUrl!)
            
            
            // load the user name
            self.usernameLabel.text = currentProfileUser.name
            
            // load the user description
            self.descTextView.text = currentProfileUser.desc
            
            //self.wholeView.isHidden = false
            
        })
    }
    
    func followUser() {
        // ADD CODE TO FOLLOW A USER
        if isFollowed {
            ref.child("users").child(profileUserID).child("followers").child((currentUser.id)!).removeValue()
            ref.child("users").child((currentUser.id)!).child("following").child(profileUserID).removeValue()
            
            self.followButton.setTitle("Follow", for: .normal)
        } else {
            
            let following : [String : String] = [profileUserID : "true"]
            
            let follower : [String : String] = [currentUser.id! : "true"]
            
            ref.child("users").child(profileUserID).child("followers").updateChildValues(follower)
            ref.child("users").child((currentUser.id)!).child("following").updateChildValues(following)
            
            self.followButton.setTitle("Following", for: .normal)
        }
        isFollowed = !isFollowed
    }
    
    func editProfile() {
        // ADD CODE TO GO TO EDIT PROFILE VIEW
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let controller = storyboard .instantiateViewController(withIdentifier: "EditProfileViewController") as?
            EditProfileViewController else { return }
//        if let selectedImage = profileImageView.image {
//            controller.selectedImage = selectedImage
//        }
        navigationController?.pushViewController(controller, animated: true)
    }

}


extension ProfileViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teamList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "teamCollectionViewCell", for: indexPath) as? TeamCollectionViewCell else {return UICollectionViewCell()}
        
        cell.logoImageView.loadImageUsingCacheWithUrlString(urlString: teamList[indexPath.row].teamLogoUrl!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(teamList[indexPath.row].teamLogoUrl)
        
        //        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        //        guard let controller = storyboard .instantiateViewController(withIdentifier: "PhotoShowController") as?
        //            PhotoShowController else { return }
        //
        //        controller.currentPhoto = photoList[indexPath.row]
        //
        //        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ProfileViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellsAcross: CGFloat = 3
        let dim = CGFloat(collectionView.bounds.width / cellsAcross)
        return CGSize(width: dim, height: dim)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0
    }
}

