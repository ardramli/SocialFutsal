//
//  ViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 02/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit
import Firebase


class LogInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var uid : String?
    var ref : FIRDatabaseReference!
    var currentUser = User.currentUser
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        handleLogin()
    }
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        handleLogin()
    }
    

    func handleLogin(){
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        if email == "" || password == "" {
            warningPopUp(withTitle: "Input Error", withMessage: "Email or Password can't be empty")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.warningPopUp(withTitle: "Input Error", withMessage: "Email or Password is incorrect")
                return
            }
           // self.getCurrentUserInfo()
            self.goToMainVC()
            self.clearTextField()
        })
    }
    func clearTextField(){
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    func goToMainVC(){
        let initController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainViewController")
        present(initController, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func getCurrentUserInfo() {
        
        ref.child("users").child(uid!).observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            let dictionary = snapshot.value as? [String: Any]
            
            User.currentUser.updateUser(withAnId: (snapshot.key), anEmail: (dictionary?["email"])! as! String, aName: (dictionary?["name"])! as! String, aScreenName: (dictionary?["userName"])! as! String, aDesc: (dictionary?["desc"])! as! String, aProfileImageURL: (dictionary?["profileImageUrl"])! as! String)
        })
        
    }
}





