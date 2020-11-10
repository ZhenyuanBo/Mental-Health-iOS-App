//
//  LoginViewController.swift
//  MHA
//
//  Created by Zhenyuan Bo on 2020-11-02.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var pwdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pwdTextField.isSecureTextEntry = true
    }
    
    @IBAction func signinPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = pwdTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) { (authResult,  error) in
                if let e = error{
                    print(e)
                }else{
                    self.performSegue(withIdentifier: "SignInToFrontView", sender: self)
                }
            }
        }
    }

}
