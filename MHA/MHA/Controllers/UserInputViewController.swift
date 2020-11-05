//
//  UserInputViewController.swift
//  MHA
//
//  Created by Zhenyuan Bo on 2020-11-02.
//

import UIKit
import Firebase

class UserInputViewController: UIViewController {


    @IBOutlet weak var textBody: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        textBody.layer.borderWidth = 10
        
    }

}
