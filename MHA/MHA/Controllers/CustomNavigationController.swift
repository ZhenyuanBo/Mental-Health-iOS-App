import UIKit

class CustomNavigationController: UINavigationController {
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = Utils.hexStringToUIColor(hex: "#c6ebc9")
    }
}
