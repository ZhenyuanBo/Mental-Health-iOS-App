/*
 Author: Zhenyuan Bo
 File Description: presents the register view
 Date: Nov 23, 2020
 */

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var alreadyMemberButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pwdTextField.isSecureTextEntry = true
//        view.backgroundColor = Utils.hexStringToUIColor(hex:"#a7c5eb")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alreadyMemberButton.setTitle("Already have an account? Sign In", for: .normal)
        alreadyMemberButton.setTitleColor(Utils.hexStringToUIColor(hex:"#ff8585"), for: .normal)
        alreadyMemberButton.layer.cornerRadius = 10
        
        registerButton.backgroundColor = Utils.hexStringToUIColor(hex:"#ff8585")
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 10
    }
    
    @IBAction func alreadyMemberButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "registerToSignIn", sender: self)
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = pwdTextField.text{
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if let e = error{
                    print("Failed to create user!, \(e)", to: &Log.log)
                }else{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                }
            }
        }
    }
    
}
