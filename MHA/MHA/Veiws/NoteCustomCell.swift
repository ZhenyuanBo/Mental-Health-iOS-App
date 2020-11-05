//
//  NoteCustomCell.swift
//  MHA
//
//  Created by Zhenyuan Bo on 2020-11-04.
//

import UIKit
import SwipeCellKit

class NoteCustomCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var noteLabel: UILabel!
    
    @IBOutlet weak var messageBubble: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageBubble.layer.cornerRadius = messageBubble.frame.size.height/5
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}



