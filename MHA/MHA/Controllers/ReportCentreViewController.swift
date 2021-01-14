/*
 Author: Zhenyuan Bo & Anqi Luo
 File Description: presents the report centre view
 Date: Jan 13, 2021
 */

import UIKit

class ReportCentreViewController: UIViewController {

    @IBOutlet weak var dailyReportImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Report Centre"
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        dailyReportImg.isUserInteractionEnabled = true
        dailyReportImg.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView

        // Your action
        print("View Daily Report")
    }
}
