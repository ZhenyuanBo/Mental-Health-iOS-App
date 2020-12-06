/*
 Author: Zhenyuan Bo
 File Description: Custom Tab Bar Controller
 Date: Dec 5, 2020
 */
import UIKit

class CustomTabViewController: UITabBarController, UITabBarControllerDelegate{
    
    let selectedTabIndexKey = "selectedTabIndex"
    var prevSelectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        if UserDefaults.standard.object(forKey: self.selectedTabIndexKey) != nil {
            prevSelectedIndex = UserDefaults.standard.integer(forKey: self.selectedTabIndexKey)
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 && prevSelectedIndex == 0{
            let alert = UIAlertController(title: "Have you saved your current note", message: "", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Yes", style: .default)
            let cancelAction = UIAlertAction(title: "No", style: .default) {(action) in
                
            }
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
}
