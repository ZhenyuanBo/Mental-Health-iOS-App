/*
 Author: Zhenyuan Bo & Anqi Luo
 File Description: Popup Window
 Date: Nov 23, 2020
 */

import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import PopupDialog

struct PopUp{
    
    static let db = Firestore.firestore()
    static let collectionName = "instruction"
    static let settingOwner = "sender"
    static let noteInstruction = "showNoteInstruction"
    static let resultsInstruction = "showResultsInstruction"
    
    static func allowDisplayInstructionDialog(VC: UIViewController, message: String){
        if let currentUser = Auth.auth().currentUser?.email{
            db.collection(collectionName).whereField(settingOwner, isEqualTo: currentUser).getDocuments {(querySnapshot, error) in
                if let e = error{
                    print("Error with retrieving instruction-dialog setting, \(e)")
                }else{
                    if let snapshotDocuments = querySnapshot?.documents{
                        if snapshotDocuments.count<1{
                            PopUp.buildInstructionDialog(VC: VC, message: message)
                        }else{
                            let data = snapshotDocuments.first?.data()
                            if message == Utils.NEED_SELECT_INSTRUCTION_MSG{
                                if let showNoteInstruct = data?[noteInstruction] as? Bool{
                                    if showNoteInstruct{
                                        PopUp.buildInstructionDialog(VC: VC, message: message)
                                    }
                                }
                            }else if message == Utils.RESULTS_INSTRUCTION_MSG{
                                if let showResultsInstruct = data?[resultsInstruction] as? Bool{
                                    if showResultsInstruct{
                                        PopUp.buildInstructionDialog(VC: VC, message: message)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func buildInstructionDialog(VC: UIViewController, message: String){
        
        let popup = PopupDialog(title: "Instruction", message: message, buttonAlignment: .vertical)
        
        let understandButton = DefaultButton(title: "Okay", dismissOnTap: true) {}
        let understandDoNotShowButton =
            DestructiveButton(title: "Do Not Show Again!", dismissOnTap: true){
                if let currentUser = Auth.auth().currentUser?.email{
                    db.collection(collectionName).whereField("sender", isEqualTo: currentUser).getDocuments {(querySnapshot, error) in
                        if let e = error{
                            print("Error with retrieving instruction-dialog setting, \(e)")
                        }else{
                            if let snapshotDocuments = querySnapshot?.documents{
                                if snapshotDocuments.count<1{
                                    if message == Utils.NEED_SELECT_INSTRUCTION_MSG{
                                        db.collection(collectionName).addDocument(
                                            data:[settingOwner: currentUser,
                                                  noteInstruction: false,
                                                  resultsInstruction: true]) { (error) in
                                            if let e = error{
                                                print("There was an issue saving note-instruction property to firestore, \(e)")
                                            }
                                        }
                                    }else if message == Utils.RESULTS_INSTRUCTION_MSG{
                                        db.collection(collectionName).addDocument(
                                            data:[settingOwner: currentUser,
                                                  noteInstruction: true,
                                                  resultsInstruction: false]) { (error) in
                                            if let e = error{
                                                print("There was an issue saving results-instruction property to firestore, \(e)")
                                            }
                                        }
                                    }
                                }else{
                                    let data = snapshotDocuments.first?.data()
                                    if message == Utils.NEED_SELECT_INSTRUCTION_MSG{
                                        if let showNoteInstruct = data?[noteInstruction] as? Bool{
                                            if showNoteInstruct{
                                                snapshotDocuments.first?.reference.updateData([noteInstruction: false])
                                            }
                                        }
                                    }else if message == Utils.RESULTS_INSTRUCTION_MSG{
                                        if let showResultsInstruct = data?[resultsInstruction] as? Bool{
                                            if showResultsInstruct{
                                                snapshotDocuments.first?.reference.updateData([resultsInstruction: false])
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        popup.addButtons([understandButton, understandDoNotShowButton])
        
        let dialogAppearance = PopupDialogDefaultView.appearance()
        
        dialogAppearance.backgroundColor      = .white
        dialogAppearance.titleFont            = .boldSystemFont(ofSize: 30)
        dialogAppearance.titleColor           = UIColor(white: 0.4, alpha: 1)
        dialogAppearance.titleTextAlignment   = .center
        dialogAppearance.messageFont          = .systemFont(ofSize: 20)
        dialogAppearance.messageColor         = UIColor(white: 0.6, alpha: 1)
        dialogAppearance.messageTextAlignment = .left
        
        let containerAppearance = PopupDialogContainerView.appearance()
        
        containerAppearance.cornerRadius    = 10
        containerAppearance.shadowEnabled   = true
        containerAppearance.shadowColor     = .black
        containerAppearance.shadowOpacity   = 0.6
        containerAppearance.shadowRadius    = 20
        containerAppearance.shadowOffset    = CGSize(width: 0, height: 8)
        
        let defaultButtonAppearance = DefaultButton.appearance()
        
        defaultButtonAppearance.titleFont      = .systemFont(ofSize: 25)
        defaultButtonAppearance.titleColor     =  .black
        defaultButtonAppearance.buttonColor = Utils.hexStringToUIColor(hex: "#61b15a")
        
        let destructiveButtonAppearance = DestructiveButton.appearance()
        destructiveButtonAppearance.titleFont = .systemFont(ofSize: 25)
        destructiveButtonAppearance.titleColor = .white
        destructiveButtonAppearance.buttonColor = UIColor(red: 1, green: 0.2196078431, blue: 0.137254902, alpha: 1)
        
        VC.present(popup, animated: true, completion: nil)
    }
}
