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
    @IBOutlet weak var playerListTableView: UITableView!

    var ref: FIRDatabaseReference!
    
    var currentUser = User.currentUser
    
    var profileUserID = ""
    var userUid : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleCreateTeam))
        
        userUid = FIRAuth.auth()?.currentUser?.uid
        
        ref = FIRDatabase.database().reference()
        
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        
        // Do any additional setup after loading the view.
    }

    @IBAction func changeLogoButtonTapped(_ sender: Any) {
        handleSelectorProfileImageView()
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        if let logInVC = storyboard?.instantiateViewController(withIdentifier: "UsersListViewController") {
            navigationController?.pushViewController(logInVC, animated: true)
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
                let teamID = teamRef.key
        
                if let teamLogo = self.imageView.image, let uploadData = UIImageJPEGRepresentation(teamLogo, 0.1) {
                    storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
        
                        if error != nil {
                            print(error!)
                            return
                        }
                        if let teamLogoUrl = metadata?.downloadURL()?.absoluteString{
                            let values = ["name" : name, "location" : location, "teamLogoUrl" : teamLogoUrl, "creatorID" : self.userUid]
                            self.registerUserIntoDatabaseWithUID(teamUid: teamID, values: values as [String : AnyObject])
                        }
                    })
                }
            dismiss(animated: true, completion: nil)
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
    
//    func listenToFirebase(){
//        
//        guard let name = teamNameTextField.text, let location = locationTextField.text
//            else {
//            return
//        }
//        if profileUserID == "" {
//            profileUserID = (uid)!
//        }
//        
//        let imageName = NSUUID().uuidString
//        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
//        
//        guard let teamUid = user?.uid else {
//            return
//        }
//        
//        if let teamLogo = self.imageView.image, let uploadData = UIImageJPEGRepresentation(teamLogo, 0.1) {
//            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
//                
//                if error != nil {
//                    print(error!)
//                    return
//                }
//                if let teamLogoUrl = metadata?.downloadURL()?.absoluteString{
//                    let values = ["name" : name, "location" : location, "teamLogoUrl" : teamLogoUrl, "username" : self.currentUser.name]
//                    self.registerUserIntoDatabaseWithUID(teamUid: uid, values: values as [String : AnyObject])
//                }
//            })
//        }
//
//    }
//    
//    func registerUserIntoDatabaseWithUID(teamUid : String, values: [String: Any]) {
//        let teamReference = ref.child("teams").child(teamUid)
//        teamReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
//            
//            if err != nil {
//                print(err!)
//                return
//            }
//        })
//
//    }

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



