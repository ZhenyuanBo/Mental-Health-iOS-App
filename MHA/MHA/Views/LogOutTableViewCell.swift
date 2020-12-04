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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.logoutButton.addTarget(self, action: #selector(logoutPressed(_:)), for: .touchUpInside)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        
    }

}
