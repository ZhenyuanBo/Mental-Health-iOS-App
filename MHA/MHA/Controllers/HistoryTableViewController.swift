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
        tableView.register(UINib(nibName: Utils.cellNibName, bundle: nil), forCellReuseIdentifier: Utils.cellNibName )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadNotes()
    }
    
    
    @IBAction func addNotesPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        //create alert
        let alert = UIAlertController(title: Utils.addNoteMsg, message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: Utils.alertAddAction, style: .default) { (alertAction) in
            
            let newHistoryNote = HistoryNote()
            newHistoryNote.subjectTitle = textField.text!
            newHistoryNote.dateCreated = Date()
            
            self.saveNote(historyNote: newHistoryNote)
            
        }
        
        alert.addTextField { (field) in
            let currentDateTime = Date()
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            formatter.dateStyle = .long
            field.text = "Note on: " + formatter.string(from: currentDateTime)
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
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell =
//            tableView.dequeueReusableCell(withIdentifier: Utils., for: indexPath) as!
//            NoteCustomCell
//            cell.layer.cornerRadius = 10
//            cell.layer.borderWidth = 2
//            cell.clipsToBounds = true
//
//        if let historyNote = historyNotes?[indexPath.section]{
//            cell.noteLabel.text = historyNote.subjectTitle
//            cell.numberLabel.text = String(indexPath.section+1)
//        }
//
//        return cell
//    }
//
    
    
    //MARK: - TableView Delegate Methods
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: K.userInputSegue, sender: self)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! UserInputViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            
        }
    }
    
    //swipe the cell to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            updateModel(at: indexPath)
            tableView.reloadData()
        }
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
    
    func updateModel(at indexPath: IndexPath){
        //update our data model
        if let noteForDeletion = self.historyNotes?[indexPath.section]{
            do{
                try self.realm.write{
                    self.realm.delete(noteForDeletion)
                }
            }catch{
                print("Error deleting category, \(error)")
            }
        }
    } 
    
}



