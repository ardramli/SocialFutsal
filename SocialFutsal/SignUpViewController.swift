//
//  SignUpViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 02/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var uid : String?
    var ref : FIRDatabaseReference!
    var currentUser = User.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectorProfileImageView)))

        // Do any additional setup after loading the view.
    }
    @IBAction func signUpButtonTapped(_ sender: Any) {
        handleSignUp()
    }

    @IBAction func signInButtonTapped(_ sender: Any) {
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func handleSignUp(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = usernameTextField.text else {
            print("Form is not valid")
            return
        }
        if email == "" || password == "" || name == "" {
            warningPopUp(withTitle: "Input Error", withMessage: "Name, Email or Password Can't Be Empty")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil {
                self.warningPopUp(withTitle: "Input Error", withMessage: "Email or Password for is invalid")
                return
            }
            
            //self.getCurrentUserInfo()
            self.goToMainVC()
            guard let uid = user?.uid else {
                return
            }
            
            
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                        let values = ["name" : name, "email" : email, "profileImageUrl" : profileImageUrl,"desc": "I love Futsal", "username" : name]
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    }
                })
            }
        })
        
    }
    func registerUserIntoDatabaseWithUID(uid : String, values: [String: Any]) {
        let ref = FIRDatabase.database().reference()
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                return
            }
        })
        
    }
    
    func goToMainVC(){
        let initController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainViewController")
        present(initController, animated: true, completion: nil)
    }
    
    func getCurrentUserInfo() {
        
        ref.child("users").child(uid!).observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            let dictionary = snapshot.value as? [String: Any]
            
            User.currentUser.updateUser(withAnId: (snapshot.key), anEmail: (dictionary?["email"])! as! String, aName: (dictionary?["name"])! as! String, aScreenName: (dictionary?["userName"])! as! String, aDesc: (dictionary?["desc"])! as! String, aProfileImageURL: (dictionary?["profileImageUrl"])! as! String)
        })
        
    }

}



extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            
            profileImageView.image = selectedImage
            profileImageView.layer.cornerRadius = 99
            profileImageView.layer.masksToBounds = true
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}


