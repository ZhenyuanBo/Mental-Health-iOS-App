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
    @IBOutlet weak var backgroundView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pwdTextField.isSecureTextEntry = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        pwdTextField.backgroundColor = Utils.hexStringToUIColor(hex:"#0E49B5")
        pwdTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        emailTextField.backgroundColor = Utils.hexStringToUIColor(hex:"#0E49B5")
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        alreadyMemberButton.setTitle("Already have an account? Sign In", for: .normal)
        alreadyMemberButton.setTitleColor(.white, for: .normal)
        alreadyMemberButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        alreadyMemberButton.backgroundColor = Utils.hexStringToUIColor(hex:"#ff4646")
        alreadyMemberButton.layer.cornerRadius = 10
        
        registerButton.backgroundColor = Utils.hexStringToUIColor(hex:"#5aa469")
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = .boldSystemFont(ofSize: 25)
        registerButton.layer.cornerRadius = 10
        
        backgroundView.alpha = 0.15
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
