/*
 Author: Zhenyuan Bo & Anqi Luo
 File Description: presents the signin view
 Date: Nov 23, 2020
 */

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var backgroundView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pwdTextField.isSecureTextEntry = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Utils.buildCredField(emailField: emailTextField, pwdField: pwdTextField)
        
        forgotPasswordButton.setTitle(Utils.FORGOT_PWD_BUTTON_TITLE, for: .normal)
        forgotPasswordButton.backgroundColor = Utils.hexStringToUIColor(hex: Utils.HELP_BUTTON_COLOUR)
        forgotPasswordButton.setTitleColor(.white, for: .normal)
        forgotPasswordButton.titleLabel?.font = .boldSystemFont(ofSize: Utils.BUTTON_TITLE_FONT)
        forgotPasswordButton.layer.cornerRadius = Utils.BUTTON_CORNER_RADIUS
        
        signInButton.backgroundColor = Utils.hexStringToUIColor(hex: Utils.SIGN_IN_BUTTON_COLOUR)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.titleLabel?.font = .boldSystemFont(ofSize: Utils.BUTTON_TITLE_FONT)
        signInButton.layer.cornerRadius = Utils.BUTTON_CORNER_RADIUS

        backgroundView.alpha = 0.15
        
    }
    
    @IBAction func signinPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = pwdTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) {(authResult,  error) in
                if let e = error{
                    var errorCode = 0
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .wrongPassword:
                            errorCode = 1
                        case .invalidEmail:
                            errorCode = 2
                        case .userNotFound:
                            errorCode = 3
                        default:
                            errorCode = 6
                        }
                    }
                    print("Fail to sign in \(e)", to: &Log.log)
                    LogInUtils.showPopup(isSuccess: false, errorCode: errorCode, vc: self)
                }else{
                    self.db.collection(Utils.FStore.collectionName).whereField(Utils.FStore.themeOwner, isEqualTo: email).getDocuments { (querySnapshot, error) in
                        if let e = error{
                            print("There was an issue with retrieving current theme, \(e)", to: &Log.log)
                        }else{
                            if let snapshotDocuments = querySnapshot?.documents{
                                let data = snapshotDocuments.first?.data()
                                if let selectedTheme = data?[Utils.FStore.selectedTheme] as? String{
                                    Theme.current = Utils.themes[selectedTheme]!
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        if let email = emailTextField.text{
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let e = error{
                    print(e, to: &Log.log)
                    LogInUtils.showPopup(isSuccess: false, errorCode: 8, vc: self)
                }else{
                    LogInUtils.showPopup(isSuccess: true)
                }
            }
        }
    }
    
}
