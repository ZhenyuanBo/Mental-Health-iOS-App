import UIKit
import RealmSwift

class UserInputViewController: UIViewController{
    
    private var savedActivityText: String?
    private var activityID: String?
    private var readonly: Bool = false
    private var selectedDate: Date = Date()
    
    @IBAction func unwind(_ unwindSegue: UIStoryboardSegue) {
        if let calendarViewController = unwindSegue.source as? CalendarViewController{
            savedActivityText = calendarViewController.selectedActivitiyText!
            selectedDate = calendarViewController.selectedDate!
        }
    }
    
    let realm = try! Realm()
    let encoder = JSONEncoder()
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var flashCard: FlashCardView!
    
    //MARK: - User Input Outlet
    @IBOutlet weak var activityText: UITextView!
    @IBOutlet weak var flipButton: UIBarButtonItem!

    private var dailyNeedMap:[String:Bool] = [:]
    private var dailyActivityMap:[String:Int] = [:]
    private var selectedNeeds: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = setTitle(date: selectedDate)
        
        populateDailyNeedMap(date: selectedDate)
        populateDailyActivityMap(date: selectedDate)
        
        flashCard.duration = 2.0
        flashCard.flipAnimation = .flipFromLeft
        flashCard.frontView = frontView
        flashCard.backView = backView
        activityText.font = .systemFont(ofSize: 18)
    }
    
    //MARK: - Button Actions
    @IBAction func flipPressed(_ sender: UIBarButtonItem) {
        flashCard.flip()
        if flashCard.backView!.isHidden && !readonly{
            flipButton.title = "Category"
            saveDailyNeedMap()
            saveDailyActivityMap()
            saveSelectedNeeds()
        }else{
            flipButton.title = "Activity"
        }
    }
    
    @IBAction func needButtonPressed(_ sender: UIButton) {
        var selectedCategory = sender.titleLabel?.text
        readonly = false
        if selectedCategory! == "personal security"{
            selectedCategory = "personal_security"
        }else if selectedCategory! == "self-esteem"{
            selectedCategory = "self_esteem"
        }else if selectedCategory! == "Self Actualization"{
            selectedCategory = "self_actualization"
        }
        if sender.titleColor(for: .normal) == UIColor.white{
            sender.setTitleColor(.black, for: .normal)
            dailyNeedMap[selectedCategory!] = true
            selectedNeeds += selectedCategory! + ","
            selectedNeeds.append(selectedCategory!)
            dailyActivityMap[selectedCategory!]! += 1
        }else{
            sender.setTitleColor(.white, for: .normal)
            dailyNeedMap[selectedCategory!] = false
            dailyActivityMap[selectedCategory!]! -= 1
        }
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        showTimePicker()
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Do you want to save data before creating a new activity", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.showTimePicker()
            self.activityText.text = ""
            self.cleanPyramidMapData()
            self.activityID = UUID.init().uuidString
        }
        let newAction = UIAlertAction(title: "No", style: .default) { (action) in
            self.activityText.text = ""
            self.cleanPyramidMapData()
            self.activityID = UUID.init().uuidString
        }
        alert.addAction(saveAction)
        alert.addAction(newAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    private func setTitle(date: Date)->String{
        let month = date.dateFormatter(format: "MM")
        let monthName = Utils.monthMap[Int(month)!]!
        let dateNumber = date.dateFormatter(format: "d")
        let navBartitle = "\(monthName) \(dateNumber)"
        return navBartitle
    }
    
    private func saveActivity(startTime: String, endTime: String){
        do{
            try self.realm.write{
                let newActivity = Activity()
                newActivity.dateCreated = Date().dateFormatter(format: "yyyy-MM-dd")
                newActivity.activityText = self.activityText.text
                newActivity.activityID = activityID!
                newActivity.startTime = startTime
                newActivity.endTime = endTime
                realm.add(newActivity, update: .modified)
            }
        }catch{
            print("Error saving new category-mapping, \(error)")
        }
    }
    
    private func saveDailyNeedMap(){
        if(!isNeedSelectionMapEmpty(needSelectionMap: dailyNeedMap)){
            if let needJSONData = try? encoder.encode(dailyNeedMap) {
                if let jsonString = String(data: needJSONData, encoding: .utf8) {
                    do{
                        try self.realm.write{
                            let newDailyNeed = DailyNeed()
                            newDailyNeed.dateCreated = Date().dateFormatter(format: "yyyy-MM-dd")
                            newDailyNeed.needResult = jsonString
                            realm.add(newDailyNeed, update: .modified)
                        }
                    }catch{
                        print("Error saving new category-mapping, \(error)")
                    }
                }
            }
        }
    }
    
    private func saveDailyActivityMap(){
        if(!isNeedNumActivityMapEmpty(needNumActivityMap: dailyActivityMap)){
            if let needActivityJSONData = try? encoder.encode(dailyActivityMap){
                if let jsonString = String(data: needActivityJSONData, encoding: .utf8){
                    do{
                        try self.realm.write{
                            let newDailyActivity = DailyActivity()
                            newDailyActivity.dateCreated = Date().dateFormatter(format: "yyyy-MM-dd")
                            newDailyActivity.numActivityResult = jsonString
                            realm.add(newDailyActivity, update: .modified)
                        }
                    }catch{
                        print("Error saving new activity-category mapping, \(error)")
                    }
                }
            }
        }
    }
    
    private func saveSelectedNeeds(){
        do{
            try self.realm.write{
                let newActivityNeed = ActivityNeed()
                newActivityNeed.selectedNeeds = selectedNeeds
                newActivityNeed.activityID = activityID!
                realm.add(newActivityNeed, update: .modified)
            }
        }catch{
            print("Error saving new category-mapping, \(error)")
        }
    }
    
    private func cleanPyramidMapData(){
        for topView in self.view.subviews as [UIView] {
            for lowerView in topView.subviews as [UIView]{
                for innerView in lowerView.subviews as [UIView]{
                    if let needButton = innerView as? UIButton {                            needButton.setTitleColor(.white, for: .normal)
                    }
                }
            }
        }
    }
    
    private func setPyramidMapData(need: String){
        for topView in self.view.subviews as [UIView] {
            for lowerView in topView.subviews as [UIView]{
                for innerView in lowerView.subviews as [UIView]{
                    if let needButton = innerView as? UIButton {
                        let buttonLabel = needButton.titleLabel?.text
                        if buttonLabel == "personal security" && need == "personal_security"{
                            needButton.setTitleColor(.black, for: .normal)
                        }else if buttonLabel == "self-esteem" && need == "self_esteem"{
                            needButton.setTitleColor(.black, for: .normal)
                        }else if buttonLabel == "Self Actualization" && need == "self_actualization" {
                            needButton.setTitleColor(.black, for: .normal)
                        }else if buttonLabel == need{
                            needButton.setTitleColor(.black, for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    private func loadActivityID(activityText: String) -> String?{
        let selectedActivity = realm.objects(Activity.self).filter("activityText = '\(activityText)'")
        if selectedActivity.count>0{
            return selectedActivity[0].activityID
        }
        return nil
    }
    
    private func populateDailyActivityMap(date: Date){
        let decodedNeedActivityData = loadDailyActivityResult(date: date)
        if let safeDecodedNeedActivityData = decodedNeedActivityData{
            for needType in Utils.needTypeList{
                dailyActivityMap[needType] = safeDecodedNeedActivityData[needType]
            }
        }
    }
    
    private func populateDailyNeedMap(date: Date){
        
        let decodedDailyNeedData = loadDailyNeed(date: date)
        
        if let safeDecodedDailyNeedData = decodedDailyNeedData{
            for needType in Utils.needTypeList{
                if safeDecodedDailyNeedData[needType]{
                    dailyNeedMap[needType] = true
                    setPyramidMapData(need: needType)
                }else{
                    dailyNeedMap[needType] = false
                }
            }
        }
    }
    
    private func isNeedSelectionMapEmpty(needSelectionMap: [String:Bool]) -> Bool{
        for key in needSelectionMap.keys{
            if (needSelectionMap[key]!){
                return false
            }
        }
        return true
    }
    
    private func isNeedNumActivityMapEmpty(needNumActivityMap: [String:Int]) -> Bool{
        for key in needNumActivityMap.keys{
            if (needNumActivityMap[key] != 0){
                return false
            }
        }
        return true
    }
    
    //MARK: - Swipe Functionality
    @objc func swipedLeft(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            performSegue(withIdentifier: Utils.userInputReportSegue, sender: self)
        }
    }
    
    @objc func swipedRight(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            performSegue(withIdentifier: Utils.userInputCalendarSegue, sender: self)
        }
    }
    
    lazy var leftSwipeGestureRecognizer: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .left
        gesture.addTarget(self, action: #selector(swipedLeft))
        return gesture
    }()
    
    lazy var rightSwipeGestureRecognizer: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .right
        gesture.addTarget(self, action: #selector(swipedRight))
        return gesture
    }()
}


extension UserInputViewController: ActivityTimePickerDelegate {
    
    @objc func showTimePicker() {
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "activitytimepicker") as! ActivityTimePicker
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = .popover
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
    func pickerAlertCancel() {
        
    }
    
    func pickerAlertSelected(t1: String, t2: String) {
        saveActivity(startTime: t1, endTime: t2)
    }
}
