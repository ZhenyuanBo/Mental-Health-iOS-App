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
                        case .emailAlreadyInUse:
                            errorCode = 4
                        case .weakPassword:
                            errorCode = 5
                        default:
                            errorCode = 6
                        }
                        }
                    print(e, to: &Log.log)
                    self.showPopup(isSuccess: false, errorCode: errorCode)

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
                    self.showPopup(isSuccess: false, errorCode: 2)
                }else{
                    self.showPopup(isSuccess: true)
                }
            }
        }
    }
    
    private func showPopup(isSuccess: Bool, errorCode: Int? = nil) {
        var errorMsg = ""
        var successMsg = ""
        if !isSuccess{
            if errorCode == 1{
                errorMsg = LogInUtils.ERROR_WRONG_PASSWORD_MSG
            }else if errorCode == 2{
                errorMsg = LogInUtils.ERROR_INVALID_EMAIL_MSG
            }else if errorCode == 3{
                errorMsg = LogInUtils.ERROR_USER_NOT_FOUND_MSG
            }else if errorCode == 4{
                errorMsg = LogInUtils.ERROR_EMAIL_IN_USE_MSG
            }else if errorCode == 5{
                errorMsg = LogInUtils.ERROR_WEAK_PASSWORD_MSG
            }else if errorCode == 6{
                errorMsg = LogInUtils.ERROR_GENERAL_MSG
            }else{
                errorMsg = Utils.PWD_RESET_ERROR_MSG
            }
        }else{
            successMsg = Utils.PWD_RESET_SUCCESS_MSG
        }
        let alert = UIAlertController(title: isSuccess ? "Success": "Error", message: isSuccess ? successMsg: errorMsg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK!", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
