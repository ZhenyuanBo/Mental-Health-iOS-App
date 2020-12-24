/*
 Author: Zhenyuan Bo
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
        
        pwdTextField.backgroundColor = Utils.hexStringToUIColor(hex:"#0E49B5")
        pwdTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        emailTextField.backgroundColor = Utils.hexStringToUIColor(hex:"#0E49B5")
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.backgroundColor = Utils.hexStringToUIColor(hex:"#ff4646")
        forgotPasswordButton.setTitleColor(.white, for: .normal)
        forgotPasswordButton.titleLabel?.font = .boldSystemFont(ofSize: 25)
        forgotPasswordButton.layer.cornerRadius = 10
        
        signInButton.backgroundColor = Utils.hexStringToUIColor(hex:"#16a596")
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.titleLabel?.font = .boldSystemFont(ofSize: 25)
        signInButton.layer.cornerRadius = 10

        backgroundView.alpha = 0.15
        
    }
    
    @IBAction func signinPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = pwdTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) {(authResult,  error) in
                if let e = error{
                    print(e, to: &Log.log)
                    self.showPopup(isSuccess: false, errorCode: 1)
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
                errorMsg = Utils.SIGN_IN_ERROR_MSG
            }else if errorCode == 2{
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
