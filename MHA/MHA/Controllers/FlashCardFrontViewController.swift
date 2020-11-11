import UIKit
import RealmSwift

class FlashCardFrontViewController: UIViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var airBtn: UIButton!
    @IBOutlet weak var waterBtn: UIButton!
    @IBOutlet weak var foodBtn: UIButton!
    @IBOutlet weak var clothingBtn: UIButton!
    @IBOutlet weak var shelterBtn: UIButton!
    @IBOutlet weak var sleetpBtn: UIButton!
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
    @IBOutlet weak var selfEsteenBtn: UIButton!
    @IBOutlet weak var recognitionBtn: UIButton!
    @IBOutlet weak var strengthBtn: UIButton!
    @IBOutlet weak var freedomBtn: UIButton!
    @IBOutlet weak var selfActualizationBtn: UIButton!
    
    private var pyramidBtnPressedMap = ["air": false, "water": false,
                                       "food": false,"clothing":false,
                                       "shelter": false,"sleep": false,
                                       "reproduction":false, "personal_security":false,
                                       "employment": false, "resources": false,
                                       "property": false, "health": false,
                                       "respect": false, "status": false,
                                       "self_esteem": false, "recognition": false,
                                       "strength": false, "freedom": false,
                                       "self_actualization": false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNeedResult()
    }
    
    @IBAction func completeBtnPressed(_ sender: UIButton) {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(pyramidBtnPressedMap) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                do{
                    try self.realm.write{
                        let newNeedResult = Need()
                        newNeedResult.dateCreated = Date().dateFormatter(format: "yyyy-MM-dd")
                        newNeedResult.needResult = jsonString
                        realm.add(newNeedResult, update: .all)
                    }
                }catch{
                    print("Error saving new activity, \(error)")
                }
            }
        }
    }
    
    @IBAction func needButtonPressed(_ sender: UIButton) {
        sender.setTitleColor(.black, for: .normal)
        switch(sender.titleLabel?.text){
        case "air":
            pyramidBtnPressedMap["air"] = true
        case "food":
            pyramidBtnPressedMap["food"] = true
        case "water":
            pyramidBtnPressedMap["water"] = true
        case "clothing":
            pyramidBtnPressedMap["clothing"] = true
        case "shelter":
            pyramidBtnPressedMap["shelter"] = true
        case "sleep":
            pyramidBtnPressedMap["sleep"] = true
        case "reproduction":
            pyramidBtnPressedMap["reproduction"] = true
        case "personal security":
            pyramidBtnPressedMap["personal_security"] = true
        case "employment":
            pyramidBtnPressedMap["employment"] = true
        case "resources":
            pyramidBtnPressedMap["resources"] = true
        case "health":
            pyramidBtnPressedMap["health"] = true
        case "property":
            pyramidBtnPressedMap["property"] = true
        case "friendship":
            pyramidBtnPressedMap["friendship"] = true
        case "intimacy":
            pyramidBtnPressedMap["intimacy"] = true
        case "family":
            pyramidBtnPressedMap["family"] = true
        case "connection":
            pyramidBtnPressedMap["connection"] = true
        case "respect":
            pyramidBtnPressedMap["respect"] = true
        case "status":
            pyramidBtnPressedMap["status"] = true
        case "self-esteem":
            pyramidBtnPressedMap["self_esteem"] = true
        case "recognition":
            pyramidBtnPressedMap["recognition"] = true
        case "strength":
            pyramidBtnPressedMap["strength"] = true
        case "freedom":
            pyramidBtnPressedMap["freedom"] = true
        case "Self Acutualization":
            pyramidBtnPressedMap["self_actualization"] = true
        default:
            fatalError("No need category is selected!")
        }
    }
    
    func loadNeedResult(){
        let currDate = Date().dateFormatter(format: "yyyy-MM-dd")
        let selectedNeed = realm.objects(Need.self).filter("dateCreated = '\(currDate)'")
        let selectedNeedResult = selectedNeed[0].needResult
        let jsonData = selectedNeedResult.data(using: .utf8)!
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(NeedData.self, from: jsonData)
            if decodedData.air{
                airBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.clothing{
                clothingBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.employment{
                employmentBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.food{
                foodBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.freedom{
                freedomBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.health{
                healthBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.personal_security{
                personalSecBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.property{
                propertyBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.recognition{
                recognitionBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.reproduction{
                reproductionBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.resources{
                resourcesBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.respect{
                respectBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.self_actualization{
                selfActualizationBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.self_esteem{
                selfEsteenBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.shelter{
                shelterBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.sleep{
                sleetpBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.status{
                statusBtn.setTitleColor(.black, for: .normal)
            }
            if decodedData.strength{
                strengthBtn.setTitleColor(.black, for: .normal)
            }
        }catch{
            print("Error retrieving decoded need result data, \(error)")
        }
    }
    
}
