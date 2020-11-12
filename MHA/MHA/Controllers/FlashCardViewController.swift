import UIKit
import RealmSwift

class FlashCardViewController: UIViewController{
    
    let realm = try! Realm()
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var flashCard: FlashCardView!
    
    //MARK: - User Input Outlet
    @IBOutlet weak var activityText: UITextView!
    
    //MARK: - Need Category Outlets
    @IBOutlet weak var airBtn: UIButton!
    @IBOutlet weak var waterBtn: UIButton!
    @IBOutlet weak var foodBtn: UIButton!
    @IBOutlet weak var clothingBtn: UIButton!
    @IBOutlet weak var shelterBtn: UIButton!
    @IBOutlet weak var sleepBtn: UIButton!
    @IBOutlet weak var reproductionBtn: UIButton!
    @IBOutlet weak var personalSecBtn: UIButton!
    @IBOutlet weak var employmentBtn: UIButton!
    @IBOutlet weak var resourcesBtn: UIButton!
    @IBOutlet weak var healthBtn: UIButton!
    @IBOutlet weak var propertyBtn: UIButton!
    @IBOutlet weak var friendshipBtn: UIButton!
    @IBOutlet weak var intimacy: UIButton!
    @IBOutlet weak var familyBtn: UIButton!
    @IBOutlet weak var connectionBtn: UIButton!
    @IBOutlet weak var respectBtn: UIButton!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var selfEsteemBtn: UIButton!
    @IBOutlet weak var recognitionBtn: UIButton!
    @IBOutlet weak var strengthBtn: UIButton!
    @IBOutlet weak var freedomBtn: UIButton!
    @IBOutlet weak var selfActualizationBtn: UIButton!
    
    private var pyramidBtnPressedMap = ["air": false, "water": false,
                                        "food": false,"clothing":false,
                                        "shelter": false,"sleep": false,
                                        "reproduction":false, "personal_security":false,
                                        "employment": false, "resources": false,
                                        "property": false, "health": false, "family": false,
                                        "respect": false, "status": false, "friendship": false,
                                        "self_esteem": false, "recognition": false,
                                        "strength": false, "freedom": false,
                                        "self_actualization": false]
    
    private var pyramidBtnNumActivityMap = ["air": 0, "water": 0,
                                            "food": 0,"clothing": 0,
                                            "shelter": 0, "sleep": 0,
                                            "reproduction": 0, "personal_security": 0,
                                            "employment": 0, "resources":0,
                                            "property":0, "health":0,"family":0,
                                            "respect":0, "status":0, "friendship": 0,
                                            "self_esteem": 0, "recognition":0,
                                            "strength": 0, "freedom": 0,
                                            "self_actualization":0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    @IBAction func flipPressed(_ sender: UIButton){
        flashCard.flip()
        if flashCard.backView!.isHidden{
            let encoder = JSONEncoder()
            if let needJSONData = try? encoder.encode(pyramidBtnPressedMap) {
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
            if let needActivityJSONData = try? encoder.encode(pyramidBtnNumActivityMap){
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
        }else{
            loadNeedResult()
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
        let numberActivities = pyramidBtnNumActivityMap[selectedCategory!]!
        let alert = UIAlertController(title: "\(selectedCategory!) is fulfilled by \(numberActivities) activity(ies)", message: "Add/Remove Activity", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            self.pyramidBtnNumActivityMap[selectedCategory!]! += 1
            if sender.titleColor(for: .normal) == UIColor.white{
                sender.setTitleColor(.black, for: .normal)
            }
            if !self.pyramidBtnPressedMap[selectedCategory!]!{
                self.pyramidBtnPressedMap[selectedCategory!] = true
            }
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .default) { (action) in
            self.pyramidBtnNumActivityMap[selectedCategory!]! -= 1
            if self.pyramidBtnNumActivityMap[selectedCategory!]! == 0{
                sender.setTitleColor(.white, for: .normal)
                self.pyramidBtnPressedMap[selectedCategory!] = false
            }
        }
        alert.addAction(addAction)
        alert.addAction(removeAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        saveActivity()
    }
    
    @IBAction func newPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Do you want to save data before creating a new activity", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.saveActivity()
            self.activityText.text = ""
        }
        let newAction = UIAlertAction(title: "No", style: .default) { (action) in
            self.activityText.text = ""
        }
        alert.addAction(saveAction)
        alert.addAction(newAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func reportPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "UserInputToResult", sender: self)
    }
    //MARK: - Data Manipulation Methods
    func setTitle(date: Date)->String{
        let month = date.dateFormatter(format: "MM")
        let monthName = Utils.monthMap[Int(month)!]!
        let dateNumber = date.dateFormatter(format: "d")
        let year = date.dateFormatter(format: "yyyy")
        let navBartitle = "\(monthName) \(dateNumber), \(year)"
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
    
    func loadNeedResult(){
        let currDate = Date().dateFormatter(format: "yyyy-MM-dd")
        let selectedNeed = realm.objects(Need.self).filter("dateCreated = '\(currDate)'")
        if selectedNeed.count > 0{
            let selectedNeedResult = selectedNeed[0].needResult
            let jsonData = selectedNeedResult.data(using: .utf8)!
            let decoder = JSONDecoder()
            do{
                let decodedData = try decoder.decode(NeedData.self, from: jsonData)
                if decodedData.air{
                    pyramidBtnPressedMap["air"] = true
                    airBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.water{
                    pyramidBtnPressedMap["water"] = true
                    waterBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.clothing{
                    pyramidBtnPressedMap["clothing"] = true
                    clothingBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.employment{
                    pyramidBtnPressedMap["employment"] = true
                    employmentBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.food{
                    pyramidBtnPressedMap["food"] = true
                    foodBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.freedom{
                    pyramidBtnPressedMap["freedom"] = true
                    freedomBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.health{
                    pyramidBtnPressedMap["health"] = true
                    healthBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.personal_security{
                    pyramidBtnPressedMap["personal_security"] = true
                    personalSecBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.property{
                    pyramidBtnPressedMap["property"] = true
                    propertyBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.recognition{
                    pyramidBtnPressedMap["recognition"] = true
                    recognitionBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.reproduction{
                    pyramidBtnPressedMap["reproduction"] = true
                    reproductionBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.resources{
                    pyramidBtnPressedMap["resources"] = true
                    resourcesBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.respect{
                    pyramidBtnPressedMap["respect"] = true
                    respectBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.self_actualization{
                    pyramidBtnPressedMap["self_actualization"] = true
                    selfActualizationBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.self_esteem{
                    pyramidBtnPressedMap["self_esteem"] = true
                    selfEsteemBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.shelter{
                    pyramidBtnPressedMap["shelter"] = true
                    shelterBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.sleep{
                    pyramidBtnPressedMap["sleep"] = true
                    sleepBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.status{
                    pyramidBtnPressedMap["status"] = true
                    statusBtn.setTitleColor(.black, for: .normal)
                }
                if decodedData.strength{
                    pyramidBtnPressedMap["strength"] = true
                    strengthBtn.setTitleColor(.black, for: .normal)
                }
            }catch{
                print("Error retrieving decoded need result data, \(error)")
            }
        }
    }
    
    
}
