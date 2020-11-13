import UIKit
import RealmSwift

class UserInputViewController: UIViewController{
    
    let realm = try! Realm()
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var flashCard: FlashCardView!
    
    //MARK: - User Input Outlet
    @IBOutlet weak var activityText: UITextView!
    
    private var needSelectionMap = ["air": false, "water": false,
                                    "food": false,"clothing":false,
                                    "shelter": false,"sleep": false,
                                    "reproduction":false, "personal_security":false,
                                    "employment": false, "resources": false,
                                    "property": false, "health": false, "family": false,
                                    "respect": false, "status": false, "friendship": false,
                                    "self_esteem": false, "recognition": false,"intimacy":false,
                                    "strength": false, "freedom": false, "connection": false,
                                    "self_actualization": false]
    
    private var needNumActivityMap = ["air": 0, "water": 0,
                                      "food": 0,"clothing": 0,
                                      "shelter": 0, "sleep": 0,
                                      "reproduction": 0, "personal_security": 0,
                                      "employment": 0, "resources":0,
                                      "property":0, "health":0,"family":0,
                                      "respect":0, "status":0, "friendship": 0,
                                      "self_esteem": 0, "recognition":0,
                                      "strength": 0, "freedom": 0,"connection": 0,
                                      "self_actualization":0, "intimacy":0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
        
        let decodedData = loadNeedSelectionMap(date: Date())
        if let safeDecodedData = decodedData{
            needSelectionMap.keys.forEach { (key) in
                if safeDecodedData[key]{
                    needSelectionMap[key] = true
                }else{
                    needSelectionMap[key] = false
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = setTitle(date: Date())
        flashCard.duration = 2.0
        flashCard.flipAnimation = .flipFromLeft
        flashCard.frontView = frontView
        flashCard.backView = backView
        activityText.font = .systemFont(ofSize: 18)
    }
    
    //MARK: - Button Actions
    @IBAction func flipPressed(_ sender: UIBarButtonItem) {
        flashCard.flip()
        if flashCard.backView!.isHidden{
            let encoder = JSONEncoder()
            if let needJSONData = try? encoder.encode(needSelectionMap) {
                if let jsonString = String(data: needJSONData, encoding: .utf8) {
                    do{
                        try self.realm.write{
                            let newNeedResult = Need()
                            newNeedResult.dateCreated = Date().dateFormatter(format: "yyyy-MM-dd")
                            newNeedResult.needResult = jsonString
                            realm.add(newNeedResult, update: .modified)
                        }
                    }catch{
                        print("Error saving new category-mapping, \(error)")
                    }
                }
            }
            if let needActivityJSONData = try? encoder.encode(needNumActivityMap){
                if let jsonString = String(data: needActivityJSONData, encoding: .utf8){
                    do{
                        try self.realm.write{
                            let newNeedActivity = NeedActivity()
                            newNeedActivity.dateCreated = Date().dateFormatter(format: "yyyy-MM-dd")
                            newNeedActivity.numActivityResult = jsonString
                            realm.add(newNeedActivity, update: .modified)
                        }
                    }catch{
                        print("Error saving new activity-category mapping, \(error)")
                    }
                }
            }
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
            needSelectionMap[selectedCategory!] = true
            needNumActivityMap[selectedCategory!]! += 1
        }else{
            sender.setTitleColor(.white, for: .normal)
            needSelectionMap[selectedCategory!] = false
            needNumActivityMap[selectedCategory!]! -= 1
        }
    }
 
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        saveActivity()
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Do you want to save data before creating a new activity", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.saveActivity()
            self.activityText.text = ""
            self.cleanPyramidMapData()
        }
        let newAction = UIAlertAction(title: "No", style: .default) { (action) in
            self.activityText.text = ""
            self.cleanPyramidMapData()
        }
        alert.addAction(saveAction)
        alert.addAction(newAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    func setTitle(date: Date)->String{
        let month = date.dateFormatter(format: "MM")
        let monthName = Utils.monthMap[Int(month)!]!
        let dateNumber = date.dateFormatter(format: "d")
        let navBartitle = "\(monthName) \(dateNumber)"
        return navBartitle
    }
    
    func saveActivity(){
        do{
            try self.realm.write{
                let newActivity = Activity()
                newActivity.dateCreated = Date().dateFormatter(format: "yyyy-MM-dd")
                newActivity.activityText = self.activityText.text
                realm.add(newActivity, update: .modified)
            }
        }catch{
            print("Error saving new category-mapping, \(error)")
        }
    }
    
    func cleanPyramidMapData(){
        for topView in self.view.subviews as [UIView] {
            for lowerView in topView.subviews as [UIView]{
                for innerView in lowerView.subviews as [UIView]{
                    if let needButton = innerView as? UIButton {                            needButton.setTitleColor(.white, for: .normal)
                    }
                }
            }
        }
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
