/*
 Author: Zhenyuan Bo
 File Description: creates logout table cell
 Date: Dec 1, 2020
 */
import UIKit

class LogOutTableViewCell: UITableViewCell {

    @IBOutlet weak var logoutButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.logoutButton.addTarget(self, action: #selector(logoutPressed(_:)), for: .touchUpInside)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        
    }

}
