import UIKit
import RealmSwift

class NotesDetailsTableViewController: UITableViewController {
    
    let realm = try! Realm()
    var activityList: Results<Activity>?
    var selectedDailyNote: DailyNotes?{
        didSet{
            loadActivities()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityList?.count ?? 1
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        //create alert
        let alert = UIAlertController(title: "Add New Activity", message: "", preferredStyle: .alert)
        let addActivityAction = UIAlertAction(title: "Add", style:.default) { (action) in
            if let currentDailyNotes = self.selectedDailyNote{
                do{
                    try self.realm.write{
                        let newActivity = Activity()
                        newActivity.activityName = textField.text!
                        currentDailyNotes.activities.append(newActivity)
                    }
                }catch{
                    print("Error saving new activity, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new activity"
            textField = alertTextField
        }
        
        alert.addAction(addActivityAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadActivities(){
        activityList = selectedDailyNote?.activities.sorted(byKeyPath: "activityName", ascending: true)
        tableView.reloadData()
    }
}
