//
//  EditProfileViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 02/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    
    let picker = UIImagePickerController()
    var ref: FIRDatabaseReference!
    
    var currentUser = User.currentUser
    
    var profileUserID = ""
    var uid : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleUpdateProfile))
        uid = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        listenToFirebase()
        
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
    }
    
    func listenToFirebase(){
    
    if profileUserID == "" {
    profileUserID = (uid)!
    }
    
    ref.child("users").child(profileUserID).observe(.value, with: { (snapshot) in
    print("Value : " , snapshot)
    
    let dictionary = snapshot.value as? [String: Any]
    
    let currentProfileUser = User(withAnId: (snapshot.key), anEmail: (dictionary?["email"])! as! String, aName: (dictionary?["name"])! as! String, aScreenName: (dictionary?["username"])! as! String, aDesc: (dictionary?["desc"])! as! String, aProfileImageURL: (dictionary?["profileImageUrl"])! as! String)
    
    
    
    // load screen name in nav bar
    self.navigationItem.title = currentProfileUser.username
    
    
    // load the profile image
    self.profileImageView.loadImageUsingCacheWithUrlString(urlString: currentProfileUser.profileImageUrl!)
    
    
    // load the user name
    self.usernameTextField.text = currentProfileUser.username
    self.fullNameTextField.text = currentProfileUser.name
    // load the user description
    self.bioTextField.text = currentProfileUser.desc
    
    //self.wholeView.isHidden = false
    
    })
    }
    
    @IBAction func changePhotoButtonTapped(_ sender: Any) {
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func handleUpdateProfile(){
        
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
        
        if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                    let update : [String : String] = ["name" : self.fullNameTextField.text!, "username" : self.usernameTextField.text!, "desc" : self.bioTextField.text!, "profileImageUrl" : profileImageUrl]
                    self.ref.child("users").child(self.uid!).updateChildValues(update)
                }
            })
        }
    }

}


extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        print("User canceled out of picker")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker
        {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
