/*
 Author: Zhenyuan Bo
 File Description: Custom Tab Bar Controller
 Date: Dec 5, 2020
 */
import UIKit

class CustomTabViewController: UITabBarController, UITabBarControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        let calNavController = tabBarController.viewControllers![1] as! UINavigationController
        let calendarVC = calNavController.topViewController as! CalendarViewController
        let selectedDate = calendarVC.selectedDate
        
        let currNavController = viewController as! UINavigationController
        if currNavController.topViewController is ResultsViewController{
            if let safeSelectedDate = selectedDate{
                let resulstsVC = currNavController.topViewController as! ResultsViewController
                resulstsVC.selectedDate = safeSelectedDate
            }
        }else if currNavController.topViewController is UserInputViewController{
            if let safeSelectedDate = selectedDate{
                let userInputVC = currNavController.topViewController as! UserInputViewController
                userInputVC.selectedDate = safeSelectedDate
            }
        }
        
        return true
    }
}
