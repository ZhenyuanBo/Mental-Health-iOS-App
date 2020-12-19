
import UIKit
import Firebase

class SignIn2ViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var passwordTextField: SignInRegTextField!
    @IBOutlet var contactPointTextField: SignInRegTextField!
    @IBOutlet var loginButton: UIButton!
    
    private let backgroundColor = Utils.hexStringToUIColor(hex: "#0997E8")
    private let tintColor = Utils.hexStringToUIColor(hex: "#ff5a66")

    private let titleFont = UIFont.boldSystemFont(ofSize: 30)
    private let buttonFont = UIFont.boldSystemFont(ofSize: 20)
    
    private let textFieldFont = UIFont.systemFont(ofSize: 16)
    private let textFieldColor = Utils.hexStringToUIColor(hex: "#B0B3C6")
    private let textFieldBorderColor = Utils.hexStringToUIColor(hex: "#B0B3C6")

    private let separatorFont = UIFont.boldSystemFont(ofSize: 14)
    private let separatorTextColor = Utils.hexStringToUIColor(hex: "#464646")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = titleFont
        titleLabel.text = "Log In"
        titleLabel.textColor = tintColor
        
        contactPointTextField.configure(color: textFieldColor,
                                        font: textFieldFont,
                                        cornerRadius: 55/2,
                                        borderColor: textFieldBorderColor,
                                        backgroundColor: backgroundColor,
                                        borderWidth: 1.0)
        contactPointTextField.placeholder = "E-mail"
        contactPointTextField.textContentType = .emailAddress
        contactPointTextField.clipsToBounds = true
        
        passwordTextField.configure(color: textFieldColor,
                                    font: textFieldFont,
                                    cornerRadius: 55/2,
                                    borderColor: textFieldBorderColor,
                                    backgroundColor: backgroundColor,
                                    borderWidth: 1.0)
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .emailAddress
        passwordTextField.clipsToBounds = true
        
        
        loginButton.setTitle("Log In", for: .normal)
        //loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
//        loginButton.configure(color: backgroundColor,
//                              font: buttonFont,
//                              cornerRadius: 55/2,
//                              backgroundColor: tintColor)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
//    @objc func didTapLoginButton() {
//        let loginManager = FirebaseAuthManager()
//        guard let email = contactPointTextField.text, let password = passwordTextField.text else { return }
//        loginManager.signIn(email: email, pass: password) {[weak self] (success) in
//            self?.showPopup(isSuccess: success)
//        }
//    }
        
    func display(alertController: UIAlertController) {
        self.present(alertController, animated: true, completion: nil)
    }
    
}

//extension ATCClassicLoginScreenViewController {
//
//    func showPopup(isSuccess: Bool) {
//        let successMessage = "User was sucessfully logged in."
//        let errorMessage = "Something went wrong. Please try again"
//        let alert = UIAlertController(title: isSuccess ? "Success": "Error", message: isSuccess ? successMessage: errorMessage, preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//}


