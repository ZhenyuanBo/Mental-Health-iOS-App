import UIKit
import RealmSwift

class DailyNotesTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var firstDay: String = ""
    var lastDay: String = ""
    var month: String = ""
    var year: String = ""
    var weekDayList: [String] = []
    var dailyActivityList: [[String]] = []
    var hiddenSections = Set<Int>()
    var selectedSection:Int?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateWeekDayList(firstDay: firstDay, lastDay: lastDay, month: month)
        tableView.separatorStyle = .none
        loadActivities()
//        for index in weekDayList.indices{
//            let currDay = weekDayList[index]
//            let newDailyNote = DailyNotes()
//            newDailyNote.date = "\(self.month) \(currDay), \(self.year)"
//            self.save(dailyNotes: newDailyNote)
//        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.weekDayList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.hiddenSections.contains(section) {
              return 0
          }
        return self.dailyActivityList[section].count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{

        let sectionButton = UIButton()
        let sectionButtonTitle = weekDayList[section]
        sectionButton.setTitle("\(month) \(sectionButtonTitle), \(year)",for: .normal)
        sectionButton.backgroundColor = hexStringToUIColor(hex: Utils.weekDayColourMap[section]!)
        sectionButton.setTitleColor(.black, for: .normal)
        sectionButton.tag = section
        sectionButton.addTarget(self,
                                action: #selector(self.hideSection(sender:)),
                                for: .touchUpInside)

        return sectionButton
    }
    
    //MARK: - Expand and collapse daily notes
    @objc
    private func hideSection(sender: UIButton) {
        let section = sender.tag
        selectedSection = section
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            
            for row in 0..<self.dailyActivityList[section].count {
                indexPaths.append(IndexPath(row: row,
                                            section: section))
            }
            
            return indexPaths
        }
        
        if self.hiddenSections.contains(section) {
            self.hiddenSections.remove(section)
            self.tableView.insertRows(at: indexPathsForSection(),
                                      with: .fade)
        } else {
            self.hiddenSections.insert(section)
            self.tableView.deleteRows(at: indexPathsForSection(),
                                      with: .fade)
        }
        performSegue(withIdentifier: Utils.notesDetailsSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NotesDetailsTableViewController
        let dailyNoteTitle = "\(month) \(weekDayList[selectedSection!]), \(year)"
        let selectedDailyNote = realm.objects(DailyNotes.self).filter("date = '\(dailyNoteTitle)'")
        destinationVC.selectedDailyNote = selectedDailyNote[0]
        destinationVC.dailyNoteSectionIndex = selectedSection!
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let activity = self.dailyActivityList[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Utils.dayCell, for: indexPath)
        cell.textLabel?.text = activity
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    //MARK: - Data Manipulation Methods
 
    func populateWeekDayList(firstDay: String, lastDay: String, month: String){
        var firstDayNumericVal = Int(firstDay)!
        let lastDayNumericVal = Int(lastDay)!

        if(firstDayNumericVal < lastDayNumericVal){
            while(firstDayNumericVal<=lastDayNumericVal){
                weekDayList.append(String(firstDayNumericVal))
                firstDayNumericVal += 1
            }
        }
    }
    
    func save(dailyNotes: DailyNotes){
        do{
            //commit changes to realm
            try realm.write{
                realm.add(dailyNotes)
            }
        }catch{
            print("Error saving daily note, \(error)")
        }
                        
        tableView.reloadData()
    }
    
    func loadActivities(){
        for index in 0...6{
            let dailyActivities = realm.objects(Activity.self).filter("dailyNoteSectionIndex=\(index)")
            print(dailyActivities)
            var dailyActivity:[String]=[]
            for activity in dailyActivities{
                dailyActivity.append(activity.activityName)
            }
            dailyActivityList.append(dailyActivity)
        }
        print(dailyActivityList)
        tableView.reloadData()
    }
}
