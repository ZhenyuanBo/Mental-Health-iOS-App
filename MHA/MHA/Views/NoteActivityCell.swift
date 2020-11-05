//
//  NoteActivityCell.swift
//  MHA
//
//  Created by Zhenyuan Bo on 2020-11-05.
//

import UIKit

class NoteActivityCell: UITableViewCell {

    @IBOutlet weak var weekDayLabel: UILabel!
    
    @IBOutlet weak var dateNumberLabel: UILabel!
    
    @IBOutlet weak var noteTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
