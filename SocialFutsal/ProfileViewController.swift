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
import Charts

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
    @IBOutlet weak var recordsView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var teamsCollectionView: UICollectionView!{
        didSet{
            teamsCollectionView.delegate = self
            teamsCollectionView.dataSource = self
        }
    }

    @IBOutlet weak var statisticsRadarChart: RadarChartView!
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            teamsView.isHidden = true
            statisticsView.isHidden = false
            recordsView.isHidden = true
        case 1:
            teamsView.isHidden = false
            statisticsView.isHidden = true
            recordsView.isHidden = true
        case 2:
            teamsView.isHidden = true
            statisticsView.isHidden = true
            recordsView.isHidden = false
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        uid = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        listenToFirebase()
        
        teamsView.isHidden = true
        statisticsView.isHidden = false
        recordsView.isHidden = true
        
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
    
    override func viewDidAppear(_ animated: Bool) {
    
        super.viewDidAppear(animated)
        
        let stats = ["ATT", "DEF", "PACE", "SHOT", "STR", "HEA"]
        let value = [92.0, 42.0, 80.0, 90.0, 78.0, 70.0]
        setRadarChart(dataPoints: stats, values: value)
    }
    
    func setRadarChart(dataPoints: [String], values: [Double]){
        var rcDataEntries = [RadarChartDataEntry]()
        for i in 0..<dataPoints.count {
            let rcDataEntry = RadarChartDataEntry(value: Double(values[i]), data: dataPoints[i] as AnyObject?)
            rcDataEntries.append(rcDataEntry)
        }
        
        let rcDataSet = RadarChartDataSet(values: rcDataEntries, label: "bla bla bla")
        rcDataSet.colors = [.red]
        rcDataSet.valueColors = [.darkGray]
        rcDataSet.fillColor = .brown
        rcDataSet.label = "WHAT"
        
        let rcData = RadarChartData(dataSets: [rcDataSet])
//        rcData.labels = ["ATT", "DEF", "PACE", "SHOT", "STR", "HEA"]
//        rcData.setLabels(labels)
        
        statisticsRadarChart.data = rcData
//        statisticsRadarChart.sizeToFit()
        statisticsRadarChart.chartDescription?.text = "huhuh"
        statisticsRadarChart.noDataText = "You need to provide data for the chart."
        statisticsRadarChart.yAxis.axisMinimum = 0.0
        statisticsRadarChart.yAxis.axisMaximum = 100.0
        statisticsRadarChart.legend.enabled = false
        statisticsRadarChart.yAxis.gridAntialiasEnabled = true
        statisticsRadarChart.animate(xAxisDuration: 2.0)
        statisticsRadarChart.animate(yAxisDuration: 2.0)
        statisticsRadarChart.isUserInteractionEnabled = false
        statisticsRadarChart.viewPortHandler.fitScreen()
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let currentStoryboard = UIStoryboard (name: "Main", bundle: Bundle.main)
        let initController = currentStoryboard.instantiateViewController(withIdentifier: "LogInViewController")
        present(initController, animated: true, completion: nil)
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
            
        })
        
        ref.child("teams").observe(.childAdded, with: { (snapshot) in
            print("Value : " , snapshot)
            
            if let team = snapshot.value as? [String: Any] {
                let newTeam = Team(withAnId: snapshot.key, aUserID: "", aTeamLogo: team["teamLogoUrl"] as! String, aTeamName: "", aTeamLocation: "", withPlayers: [""])
                 self.teamList.append(newTeam)
            }
            self.teamsCollectionView.reloadData()
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

