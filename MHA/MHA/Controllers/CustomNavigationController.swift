/*
 Author: Zhenyuan Bo & Anqi Luo
 File Description: Custom Navigation Controller
 Date: Dec 22, 2020
 */


import UIKit

class CustomNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = Utils.hexStringToUIColor(hex: Utils.NAV_BAR_COLOUR)
    }
}
