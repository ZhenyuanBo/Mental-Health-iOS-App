//
//  UserInputViewController.swift
//  MHA
//
//  Created by Zhenyuan Bo on 2020-11-02.
//

import UIKit
import Firebase

class UserInputViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func signoutPressed(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }catch let signOutError as NSError{
            print("Error signing out: %@", signOutError)
        }
    }
}
