/*
 Author: Zhenyuan Bo & Anqi Luo
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
        
        Utils.buildCredField(emailField: emailTextField, pwdField: pwdTextField)
        
        alreadyMemberButton.setTitle(Utils.ALREADY_MEMBER_BUTTON_TITLE, for: .normal)
        alreadyMemberButton.setTitleColor(.white, for: .normal)
        alreadyMemberButton.titleLabel?.font = .boldSystemFont(ofSize: Utils.ALREADY_MEMBER_BUTTON_TITLE_FONT)
        alreadyMemberButton.backgroundColor = Utils.hexStringToUIColor(hex: Utils.HELP_BUTTON_COLOUR)
        alreadyMemberButton.layer.cornerRadius = Utils.BUTTON_CORNER_RADIUS
        
        registerButton.backgroundColor = Utils.hexStringToUIColor(hex: Utils.REGISTER_BUTTON_COLOUR)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = .boldSystemFont(ofSize: Utils.BUTTON_TITLE_FONT)
        registerButton.layer.cornerRadius = Utils.BUTTON_CORNER_RADIUS
        
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
