/*
 Author: Zhenyuan Bo
 File Description: presents the user input view
 Date: Nov 23, 2020
 */

import UIKit
import Firebase
import FirebaseFirestore
import RealmSwift

class UserInputViewController: UIViewController, UITabBarControllerDelegate, UITextViewDelegate{
    
    let db = Firestore.firestore()
    let realm = try! Realm()
    let encoder = JSONEncoder()
    
    var savedActivityText: String?
    var activityID: String?
    
    var selectedDate: Date = Date()
    var selectedStartTime: String = ""
    var selectedEndTime: String = ""
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var flashCard: FlashCardView!
    
    @IBOutlet weak var activityText: UITextView!
    @IBOutlet weak var flipButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var instructionButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    private var dailyActivityMap:[String:Int] = [:]
    private var selectedNeeds: String = ""
    
    //MARK: - Unwind Action from CalendarView
    @IBAction func unwind(_ unwindSegue: UIStoryboardSegue) {
        if let calendarViewController = unwindSegue.source as? CalendarViewController{
            if let safeSelectedActivityText = calendarViewController.selectedActivitiyText{
                savedActivityText = safeSelectedActivityText
            }else{
                savedActivityText = ""
            }
            if let safeSelectedDate = calendarViewController.selectedDate{
                selectedDate = safeSelectedDate
            }
            if let safeStartTime = calendarViewController.selectedStartTime, let safeEndTime = calendarViewController.selectedEndTime{
                selectedStartTime = safeStartTime
                selectedEndTime = safeEndTime
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for need in Utils.needTypeList{
            dailyActivityMap[need] = 0
        }
        
        instructionButton.isEnabled = false
        instructionButton.tintColor = .clear
        
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
        activityText.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if let currentThemeOwner = Auth.auth().currentUser?.email{
            loadAppTheme(withEmail: currentThemeOwner, view: view)
        }
        
        title = setTitle(date: selectedDate)
        
        if let safeActivityText = savedActivityText{
            activityText.text = safeActivityText
            if safeActivityText != ""{
                activityID = loadActivityID(activityText: safeActivityText)
                activityText.textColor = UIColor.black
            }else{
                activityID = UUID.init().uuidString
                setTextViewPlaceHolder()
            }
        }else if activityText.text.isEmpty{
            activityID = UUID.init().uuidString
            setTextViewPlaceHolder()
        }
        
        populateDailyActivityMap(date: selectedDate)
        cleanPyramidMapData()
        
        configureNeedButton()
        
        if let safeActivityID = activityID{
            populateSelectedNeed(activityID: safeActivityID)
        }
        
        frontView.layer.cornerRadius = 25
        backView.layer.cornerRadius = 25

        configureFlashCard(flashCard: flashCard, front: frontView, back: backView)
        
        activityText.font = .systemFont(ofSize: 18)
        frontView.backgroundColor = hexStringToUIColor(hex: "#98acf8")
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text as NSString).rangeOfCharacter(from: CharacterSet.newlines).location == NSNotFound {
            return true
        }
        activityText.resignFirstResponder()
        return false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        selectedNeeds = ""
        for need in dailyActivityMap.keys{
            dailyActivityMap[need] = 0
        }
    }
    
    //MARK: - Button Actions
    @IBAction func flipPressed(_ sender: UIBarButtonItem) {
        flashCard.flip()
        if flashCard.showFront{
            instructionButton.isEnabled = true
            instructionButton.tintColor = .systemBlue
            
            trashButton.isEnabled = false
            trashButton.tintColor = .clear
            
            saveButton.isEnabled = false
            saveButton.tintColor = .clear
            
            addButton.isEnabled = false
            addButton.tintColor = .clear
        }else{
            instructionButton.isEnabled = false
            instructionButton.tintColor = .clear
            
            trashButton.isEnabled = true
            trashButton.tintColor = .systemBlue
            
            saveButton.isEnabled = true
            saveButton.tintColor = .systemBlue
            
            addButton.isEnabled = true
            addButton.tintColor = .systemBlue
        }
    }
    
    @IBAction func needButtonPressed(_ sender: UIButton) {
        var selectedCategory = sender.titleLabel?.text
        if selectedCategory! == "personal security"{
            selectedCategory = "personal_security"
        }else if selectedCategory! == "self-esteem"{
            selectedCategory = "self_esteem"
        }else if selectedCategory! == "Self Actualization"{
            selectedCategory = "self_actualization"
        }
        if sender.titleColor(for: .normal) == UIColor.white{
            sender.setTitleColor(.black, for: .normal)
            selectedNeeds += " " + selectedCategory!
            dailyActivityMap[selectedCategory!]! += 1
        }else{
            sender.setTitleColor(.white, for: .normal)
            dailyActivityMap[selectedCategory!]! -= 1
        }
    }
    
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        var activityToDeleteDateCreated = ""
        
        let activityToDelete = realm.objects(Activity.self).filter("activityID = '\(activityID!)'")
        
        if activityToDelete.count>0{
            activityToDeleteDateCreated = activityToDelete[0].dateCreated
            
            let activityNeedToDelete = realm.objects(ActivityNeed.self).filter("activityID='\(activityID!)'")
            
            if activityNeedToDelete.count>0{
                let selectedNeedsToDelete = activityNeedToDelete[0].selectedNeeds
                let selectedNeedsToDeleteArray = selectedNeedsToDelete.components(separatedBy: " ")
                
                let dailyActivityToModify = realm.objects(DailyActivity.self).filter("dateCreated = '\(activityToDeleteDateCreated)'")
                if dailyActivityToModify.count>0{
                    let result = dailyActivityToModify[0].numActivityResult
                    let jsonData = result.data(using: .utf8)!
                    let decoder = JSONDecoder()
                    do{
                        let decodedData = try decoder.decode(DailyActivityData.self, from: jsonData)
                        var newData:[String:Int] = [:]
                        for need in Utils.needTypeList{
                            if selectedNeedsToDeleteArray.contains(need){
                                newData[need] = decodedData[need]-1
                            }else{
                                newData[need] = decodedData[need]
                            }
                        }
                        if let newJSONData = try? encoder.encode(newData){
                            if let jsonString = String(data: newJSONData, encoding: .utf8){
                                do{
                                    try self.realm.write{
                                        let newDailyActivity = DailyActivity()
                                        newDailyActivity.dateCreated = activityToDeleteDateCreated
                                        newDailyActivity.numActivityResult = jsonString
                                        realm.add(newDailyActivity, update: .modified)
                                        realm.delete(activityToDelete[0])
                                        realm.delete(activityNeedToDelete[0])
                                        savedActivityText = ""
                                        activityText.text = ""
                                    }
                                }catch{
                                    print("Error saving modified daily activity object, \(error)")
                                }
                            }
                        }
                    }catch{
                        print("Error retrieving decoded need DailyActivity data, \(error)")
                    }
                }
            }
        }else{
            print("No such activity with ID: \(activityID!) to be deleted")
        }
    }
    
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        showTimePicker()
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        alertMessageCreator()
        setTextViewPlaceHolder()
        selectedNeeds = ""
    }
    
    @IBAction func instructionPressed(_ sender: UIBarButtonItem) {
        displayInstruction()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Utils.userInputReportSegue{
            let destinationVC = segue.destination as! ResultsViewController
            destinationVC.selectedDate = selectedDate
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if activityText.textColor == UIColor.lightGray{
            activityText.text = nil
            activityText.textColor = UIColor.black
        }
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
                newActivity.dateCreated = selectedDate.dateFormatter(format: "yyyy-MM-dd")
                newActivity.activityText = self.activityText.text
                newActivity.activityID = activityID!
                newActivity.startTime = startTime
                newActivity.endTime = endTime
                newActivity.colour = Utils.eventColours[Int(arc4random_uniform(UInt32(Utils.eventColours.count)))]
                realm.add(newActivity, update: .modified)
            }
            saveDailyActivityMap(date: selectedDate)
            saveSelectedNeeds()
        }catch{
            print("Error saving new category-mapping, \(error)")
        }
    }
    
    private func saveDailyActivityMap(date: Date){
        if(!isNeedNumActivityMapEmpty(needNumActivityMap: dailyActivityMap)){
            if let needActivityJSONData = try? encoder.encode(dailyActivityMap){
                if let jsonString = String(data: needActivityJSONData, encoding: .utf8){
                    do{
                        try self.realm.write{
                            let newDailyActivity = DailyActivity()
                            newDailyActivity.dateCreated = date.dateFormatter(format: "yyyy-MM-dd")
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
                selectedNeeds = selectedNeeds.trimmingCharacters(in: .whitespacesAndNewlines)
                print(selectedNeeds)
                newActivityNeed.selectedNeeds = selectedNeeds
                newActivityNeed.activityID = activityID!
                realm.add(newActivityNeed, update: .modified)
            }
        }catch{
            print("Error saving new selected needs, \(error)")
        }
    }
    
    private func cleanPyramidMapData(){
        for innerView in backView.subviews as [UIView]{
            if let needButton = innerView as? UIButton {                            needButton.setTitleColor(.white, for: .normal)
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
    
    private func populateSelectedNeed(activityID: String){
        let selectedActivityNeed = realm.objects(ActivityNeed.self).filter("activityID = '\(activityID)'")
        if selectedActivityNeed.count>0{
            selectedNeeds = selectedActivityNeed[0].selectedNeeds
            let selectedNeedsArray = selectedNeeds.components(separatedBy: " ")
            for need in selectedNeedsArray{
                setPyramidMapData(need: need)
            }
        }else{
            selectedNeeds = ""
        }
    }
    
    private func setPyramidMapData(need: String){
        for innerView in backView.subviews as [UIView]{
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
    
    private func configureNeedButton(){
        for innerView in backView.subviews as [UIView]{
            if let needButton = innerView as? UIButton {
                needButton.layer.cornerRadius = 8.0
            }
        }
    }
    
    private func isNeedNumActivityMapEmpty(needNumActivityMap: [String:Int]) -> Bool{
        for key in needNumActivityMap.keys{
            if (needNumActivityMap[key] != 0){
                return false
            }
        }
        return true
    }
    
    private func alertMessageCreator(){
        let alert : UIAlertController?
        let alertTitle = Utils.saveNoteAlertMsg
        
        alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Yes", style: .default) {(action) in
            self.activityText.text = ""
            self.activityID = UUID.init().uuidString
            self.cleanPyramidMapData()
        }
        let newAction = UIAlertAction(title: "No", style: .default) {(action) in
            self.showTimePicker()
        }
        alert!.addAction(saveAction)
        alert!.addAction(newAction)
        present(alert!, animated: true, completion: nil)
    }
    
    private func setTextViewPlaceHolder(){
        activityText.text = Utils.activityDefaultMsg
        activityText.textColor = UIColor.lightGray
    }
    
    private func displayInstruction(){
        showInstructionDialog(VC: self, message: Utils.needSelectInstructionMsg)
    }
    
    //MARK: - Swipe Functionality
    @objc func swipedLeft(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            performSegue(withIdentifier: "unwindToResults", sender: self)
        }
    }
    
    @objc func swipedRight(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            performSegue(withIdentifier: "unwindToCalendar", sender: self)
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
        customAlert.modalPresentationStyle = .overCurrentContext
        customAlert.modalTransitionStyle = .crossDissolve
        customAlert.delegate = self
        if selectedStartTime != "" && selectedEndTime != ""{
            customAlert.selectedStartTime = selectedStartTime
            customAlert.selectedEndTime = selectedEndTime
        }
        self.present(customAlert, animated: true, completion: nil)
    }
    
    func pickerAlertCancel() {}
    
    func pickerAlertSelected(t1: String, t2: String) {
        saveActivity(startTime: t1, endTime: t2)
    }
}
