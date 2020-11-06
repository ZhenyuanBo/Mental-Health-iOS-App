import UIKit

class WeekCell: UITableViewCell {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var weekView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
