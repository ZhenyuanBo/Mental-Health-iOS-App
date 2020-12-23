/*
 Author: Zhenyuan Bo
 File Description: presents the welcome view
 Date: Nov 23, 2020
 */

import UIKit

class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var signinButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        signinButton.setTitle("Sign In", for: .normal)
        registerButton.setTitle("Register", for: .normal)
        
        signinButton.setTitleColor(.white, for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        
        signinButton.backgroundColor = Utils.hexStringToUIColor(hex:"#0E49B5")
        registerButton.backgroundColor = Utils.hexStringToUIColor(hex:"#0E49B5")
        
        signinButton.layer.cornerRadius = 10
        registerButton.layer.cornerRadius = 10
    }
}

