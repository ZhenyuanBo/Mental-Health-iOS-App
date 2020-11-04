//
//  HistoryTableViewController.swift
//  MHA
//
//  Created by Zhenyuan Bo on 2020-11-03.
//

import UIKit
import SwipeCellKit
import RealmSwift

class HistoryTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var historyNotes: Results<HistoryNote>?
    
    let cellSpacing: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        tableView.separatorStyle = .none
        tableView.rowHeight = 60.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadNotes()
    }
    
    
    @IBAction func addNotesPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        //create alert
        let alert = UIAlertController(title: K.addNoteMsg, message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: K.alertAddAction, style: .default) { (alertAction) in
            
            var currentValue = self.historyNotes?.count ?? 0
            currentValue = currentValue + 1
            
            let newHistoryNote = HistoryNote()
            newHistoryNote.subjectTitle = "\(currentValue): " + textField.text!
            newHistoryNote.dateCreated = Date()
            
            self.saveNote(historyNote: newHistoryNote)
            
        }
        
        alert.addTextField { (field) in
            let currentDateTime = Date()
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            formatter.dateStyle = .long
            field.text = "Note for: " + formatter.string(from: currentDateTime)
            textField = field
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }

    // MARK: - TableView Datasource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return historyNotes?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacing
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2
        cell.clipsToBounds = true
        
        if let historyNote = historyNotes?[indexPath.section]{
            cell.textLabel?.text = historyNote.subjectTitle
        }else{
            cell.textLabel?.text = "No Notes Added Yet"
        }
        
        return cell
    }
    
    // MARK: - Data Manipulation Methods
    
    func saveNote(historyNote: HistoryNote){
        do{
            try realm.write{
                realm.add(historyNote)
            }
        }catch{
            print("Error saving history note, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadNotes(){
        historyNotes = realm.objects(HistoryNote.self)
        tableView.reloadData()
    }
    
    
}


//MARK: - SwipeTableViewCell Delegate Methods
//extension HistoryTableViewController: SwipeTableViewCellDelegate{
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//
//    }
//}
