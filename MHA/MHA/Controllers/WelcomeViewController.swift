/*
 Author: Zhenyuan Bo
 File Description: presents the welcome view
 Date: Nov 23, 2020
 */

import UIKit

class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var signinButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var welcomeCover: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        signinButton.setTitle("Sign In", for: .normal)
        registerButton.setTitle("Register", for: .normal)
        
        signinButton.setTitleColor(.white, for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        
        signinButton.backgroundColor = Utils.hexStringToUIColor(hex:"#16a596")
        registerButton.backgroundColor = Utils.hexStringToUIColor(hex:"#f6830f")
        
        signinButton.layer.cornerRadius = 10
        registerButton.layer.cornerRadius = 10
        
        signinButton.titleLabel?.font = .boldSystemFont(ofSize: 25)
        registerButton.titleLabel?.font = .boldSystemFont(ofSize: 25)
        
        welcomeCover.alpha = 0.2
    }
}

