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
        signinButton.setTitle(Utils.SIGN_IN_BUTTON_TITLE, for: .normal)
        registerButton.setTitle(Utils.REGISTER_BUTTON_TITLE, for: .normal)
        
        signinButton.setTitleColor(.white, for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        
        signinButton.backgroundColor = Utils.hexStringToUIColor(hex:Utils.SIGN_IN_BUTTON_COLOUR)
        registerButton.backgroundColor = Utils.hexStringToUIColor(hex:Utils.REGISTER_BUTTON_COLOUR)
        
        signinButton.layer.cornerRadius = 10
        registerButton.layer.cornerRadius = 10
        
        signinButton.titleLabel?.font = .boldSystemFont(ofSize: Utils.SIGN_IN_BUTTON_TITLE_FONT)
        registerButton.titleLabel?.font = .boldSystemFont(ofSize: Utils.REGISTER_BUTTON_TITLE_FONT)
        
        welcomeCover.alpha = 0.2
    }
}

