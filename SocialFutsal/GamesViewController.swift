//
//  GamesViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 05/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit
import Firebase

class GamesViewController: UIViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var findGamesView: UIView!
    @IBOutlet weak var organizeGameView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var hourSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var dropDown: HADropDown!

    var selectedVenue : Location!
    var timeDuration : Int = 0
    var gameType : String = ""
    var hostId : String = ""
    var userUid : String?
    var ref: FIRDatabaseReference!
    var gameID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        organizeGameView.isHidden = true
        findGamesView.isHidden = false
        dropDown.items = ["Open Game", "Friendly Match", "Tournament"]
        dropDown.delegate = self
        
        userUid = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (selectedVenue != nil) {
            locationButton.setTitle(selectedVenue.name, for: .normal)
        }
    }
    @IBAction func indexChanged(_ sender: Any) {
        
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                organizeGameView.isHidden = true
                findGamesView.isHidden = false
            case 1:
                organizeGameView.isHidden = false
                findGamesView.isHidden = true
            default:
                break;
        }
    }
    
    @IBAction func chooseLocationTapped(_ sender: Any) {
        
        if let initController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController {
        initController.delegate = self
            present(initController, animated: true, completion: nil)
        }
    }
    
    @IBAction func showDateTimePicker(sender: AnyObject) {
        let min = Date()
        let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
        let picker = DateTimePicker.show(minimumDate: min, maximumDate: max)
        picker.highlightColor = UIColor(red: 253.0/255.0, green: 203.0/255.0, blue: 3.0/255.0, alpha: 1)
        picker.darkColor = UIColor.darkGray
        picker.doneButtonTitle = "!! DONE DONE !!"
        picker.todayButtonTitle = "Today"
        picker.is12HourFormat = true
        picker.dateFormat = "hh:mm aa dd/MM/YYYY"
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            self.dateLabel.text = formatter.string(from: date)
            
        }
        
    }
    @IBAction func sliderChangesValue(_ sender: UISlider) {
        let duration = Int(sender.value)
        durationLabel.text = "\(duration) hour/s"
        timeDuration = duration
    }
    @IBAction func createButtonTapped(_ sender: Any) {
        handleCreateGame()
    }
    
    func handleCreateGame(){
        guard let location = selectedVenue
            else {
                return
        }
        
        
        if hostId == "" {
            hostId = (userUid)!
        }
        
        
        let teamRef = ref.childByAutoId()
        self.gameID = teamRef.key
        
        
        // >>> start loading screen here
        
        let values = ["hostID" : hostId, "location": location.name, "time": self.dateLabel.text ?? "", "duration": self.durationLabel.text, "gameType": self.gameType, "teams": "", "price" : self.selectedVenue.price] as [String : Any]
        
        self.registerUserIntoDatabaseWithUID(gameUid: self.gameID, values: values as [String : AnyObject])
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let controller = storyboard .instantiateViewController(withIdentifier: "GamesCreatedViewController") as?
            GamesCreatedViewController else { return }
        navigationController?.pushViewController(controller, animated: true)
        
        
    }
    
    func registerUserIntoDatabaseWithUID(gameUid : String, values: [String: Any]) {
        let teamReference = ref.child("games").child(gameUid)
        teamReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            // >> stop loading screen
            
            if err != nil {
                print(err!)
                return
            }
//            if let teamProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "TeamViewController") as? TeamViewController {
//                teamProfileVC.currentTeamID = self.teamID
//                teamProfileVC.players = self.players
//                self.navigationController?.pushViewController(teamProfileVC, animated: true)
//            }
            
        })
        
    }

}

extension GamesViewController: LocationDelegate {
    func passLocation (_ selectedVenue: Location){
        self.selectedVenue = selectedVenue
    }
}

extension GamesViewController: HADropDownDelegate {
    func didSelectItem(dropDown: HADropDown, at index: Int) {
        print("Item selected at index \(index)")
        self.gameType = dropDown.title
        
    }
}
