//
//  FlashCardFrontViewController.swift
//  MHA
//
//  Created by Zhenyuan Bo on 2020-11-10.
//

import UIKit

class FlashCardFrontViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func needButtonPressed(_ sender: UIButton) {
        switch(sender.titleLabel?.text){
        case "air":
            sender.setTitleColor(.black, for: .normal)
        default:
            sender.setTitleColor(.red, for: .normal)
        }
    }

}
