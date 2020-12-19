import UIKit
import Foundation
import DateToolsSwift
import RealmSwift
import Firebase
import FirebaseFirestore
import PopupDialog

class Utils{
    
    //MARK: - Segue Identifiers
    public static let USER_INPUT_REPORT_SEGUE = "UserInputToResult"
    public static let RESULTS_STATS_SEGUE = "ResultToStats"
    
    
    //MARK: - Month
    
    public static let MONTH_MAP = [1:"Jan", 2: "Feb", 3: "Mar", 4:"Apr",
                                  5:"May", 6:"Jun", 7:"Jul",
                                  8:"Aug", 9: "Sept", 10: "Oct", 11: "Nov", 12: "Dec"]
    
    //MARK: - Maslow Need Label
    public static let NEED_TYPE_LIST = ["air","water","food","clothing",
                                      "shelter","sleep","reproduction",
                                      "personal_security","employment",
                                      "resources","property","health",
                                      "family","respect", "status","intimacy",
                                      "friendship","self_esteem","recognition",
                                      "strength","freedom","self_actualization", "connection"]
    
    public static let PHY_NEEDS = ["reproduction","air","shelter","sleep","water","food","clothing"]
    public static let SAFETY_NEEDS = ["personal_security","employment",
                                     "resources","property","health"]
    public static let LOVE_NEEDS = ["friendship", "intimacy", "family", "connection"]
    public static let ESTEEM_NEEDS = ["respect","self_esteem","status","recognition", "strength","freedom"]
    public static let SELF_ACTUAL_NEEDS  = ["self_actualization"]
    
    public static let PHY_NEED_NAME = "Physiological"
    public static let SAFETY_NEED_NAME = "Safety"
    public static let LOVE_BELONGING_NEED_NAME = "Love & Belonging"
    public static let ESTEEM_NEED_NAME = "Esteem"
    public static let SELF_ACTUAL_NEED_NAME = "Self-Actualization"
    
    
    //MARK: - Maslow Need Data
    public static let PHY_INDEX_MAP = ["reproduction": 0, "air": 1, "shelter": 2,
                                             "sleep": 3, "water": 4, "food": 5, "clothing": 6]
    public static let SAFETY_INDEX_MAP = ["personal_security":0, "employment":1,
                                        "resources":2,"property":3,"health":4]
    public static let LOVE_INDEX_MAP = ["friendship":0, "intimacy":1, "family":2, "connection":3]
    public static let ESTEEM_INDEX_MAP = ["respect":0,"self_esteem":1,"status":2,"recognition":3, "strength":4,"freedom":5]
    public static let SELF_ACTUAL_INDEX_MAP = ["self_actualization":0]
    
    
    //MARK: - Maslow Need Colours
    public static let BASE_COLOUR = "#7e7474"
    public static let PHY_NEED_COLOUR_LIST = ["#E97452","#D65D42",
                                            "#C34632","#B12E21","#9E1711","#8B0001","#4B0A0E"]
    public static let SAFETY_NEED_COLOUR_LIST = ["#FDB777", "#FDA766", "#FD9346", "#FD7F2C", "#FF6200"]
    public static let LOVE_NEED_COLOUR_LIST = ["#FFF192", "#FFEA61", "#FFDD3C", "#FFD400"]
    public static let ESTEEM_NEED_COLOUR_LIST = ["#B7FFBF","#95F985","#4DED30","#26D701","#00C301", "#00AB08"]
    public static let SELF_ACTUAL_NEED_COLOUR_LIST = ["#00008b"]
    public static let NEED_COLOUR_MAP = [PHY_NEEDS: "#a20a0a", SAFETY_NEEDS: "#db6400", LOVE_NEEDS: "#ffa62b", ESTEEM_NEEDS: "#03c4a1", SELF_ACTUAL_NEEDS: "#005086"]
    
    //MARK: - Calendar Event Colours
    public static let EVENT_COLOUR_LIST = ["#9ad3bc","#fd8c04", "#9088d4", "#f3bad6", "#9ddfd3",
                                      "#ffa36c", "#bedbbb", "#0e918c", "#a6f6f1", "#edcfa9"]
    
    
    //MARK: - Messages
    public static let SAVE_NOTE_ALERT_MSG = "Have you saved your current note?"
    public static let RESULTS_INSTRUCTION_MSG = "1. Tap on each level tag to view activity progression.\n2. Tap inside each level to view detailed data"
    public static let ACTIVITY_DEFAULT_MSG = "Please compose your activity here..."
    public static let NEED_SELECT_INSTRUCTION_MSG = "1. Select needs that activity has fulfilled\n 2. Click on the selected need if you want to deselect it"
    public static let PIE_CHART_TITLE = "Daily Activity Overview"
    
    //MARK: - App Themes
    public static let themes:[String: ThemeProtocol] = [
        "Light":LightTheme(),
        "Natural Elegance":NaturalEleganceTheme(),
        "Fiery Red Landscape":FieryRedLanscapeTheme(),
        "Summer Blueberries":SummerBlueberriesTheme(),
        "Dock of Bay":BayDockTheme(),
        "Earthy Greens":EarthyGreensTheme(),
        "Berries Galore": BerriesGaloreTheme(),
        "Tropical":TropicalTheme(),
        "Lemon":LemonTheme(),
        "Romantic":RomanticTheme(),
        "Winter Barn":WinterBarnTheme()
    ]
    
    struct FStore {
        static let collectionName = "themes"
        static let themeOwner = "sender"
        static let selectedTheme = "selectedTheme"
    }
    
    //MARK: - Hex to UIColor
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //MARK: - Populate Daily-Need & Daily-Activity Map
    static func loadDailyNeed(date: Date)-> DailyNeedData? {
        let realm = try! Realm()
        var selectedNeed:Results<DailyNeed>
        
        let currDate = date.dateFormatter(format: "yyyy-MM-dd")
        selectedNeed = realm.objects(DailyNeed.self).filter("dateCreated = '\(currDate)'")
        
        if selectedNeed.count > 0{
            let selectedNeedResult = selectedNeed[0].needResult
            let jsonData = selectedNeedResult.data(using: .utf8)!
            let decoder = JSONDecoder()
            do{
                let decodedData = try decoder.decode(DailyNeedData.self, from: jsonData)
                return decodedData
            }catch{
                print("Fail to decode need-selection data, \(error)")
            }
        }
        return nil
    }
    
    static func loadDailyActivityResult(date: Date)-> DailyActivityData? {
        let realm = try! Realm()
        let currDate = date.dateFormatter(format: "yyyy-MM-dd")
        let selectedDailyActivity = realm.objects(DailyActivity.self).filter("dateCreated = '\(currDate)'")
        if selectedDailyActivity.count > 0{
            let result = selectedDailyActivity[0].numActivityResult
            let jsonData = result.data(using: .utf8)!
            let decoder = JSONDecoder()
            do{
                let decodedData = try decoder.decode(DailyActivityData.self, from: jsonData)
                return decodedData
            }catch{
                print("Error retrieving decoded need result data, \(error)")
            }
        }
        return nil
    }
    
    //MARK: - Load Current Theme
    static func loadAppTheme(withEmail email: String, view: UIView){
        let db = Firestore.firestore()
        db.collection(Utils.FStore.collectionName).whereField(Utils.FStore.themeOwner, isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let e = error{
                print("There was an issue with retrieving current theme, \(e)")
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    let data = snapshotDocuments.first?.data()
                    if let selectedTheme = data?[Utils.FStore.selectedTheme] as? String{
                        DispatchQueue.main.async {
                            Theme.current = Utils.themes[selectedTheme]!
                            view.backgroundColor = Theme.current.background
                        }
                    }
                }
            }
        }
    }


}

//MARK: - Date Extension
extension Date {
    func dateFormatter(format: String) -> String {
        let f = DateFormatter()
        f.timeZone = .autoupdatingCurrent
        f.dateFormat = format
        return f.string(from: self)
    }
    
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}
        
        return localDate
    }
    
    static func getDate(dateStr: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: dateStr) // replace Date String
    }
    
    static func getDates(forLastNDays nDays: Int) -> [String] {
        let cal = NSCalendar.current
        // start with today
        var date = cal.startOfDay(for: Date())
        
        var arrDates = [String]()
        
        for _ in 1 ... nDays {
            // move back in time by one day:
            date = cal.date(byAdding: Calendar.Component.day, value: -1, to: date)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            arrDates.insert(dateString, at: 0)
        }
        return arrDates
    }
}

//MARK: - FLASH CARD Utils
enum FlipAnimations
{
    case flipFromLeft
    case flipFromRight
    case flipFromTop
    case flipFromBottom
    
    func animationOption() -> UIView.AnimationOptions
    {
        switch self
        {
        case .flipFromLeft:
            return .transitionFlipFromLeft
        case .flipFromRight:
            return .transitionFlipFromRight
        case .flipFromTop:
            return .transitionFlipFromTop
        case .flipFromBottom:
            return .transitionFlipFromBottom
        }
    }
}


//MARK: - Calendar Extension
extension TimeChunk {
    static func dateComponents(seconds: Int = 0,
                               minutes: Int = 0,
                               hours: Int = 0,
                               days: Int = 0,
                               weeks: Int = 0,
                               months: Int = 0,
                               years: Int = 0) -> TimeChunk {
        return TimeChunk(seconds: seconds,
                         minutes: minutes,
                         hours: hours,
                         days: days,
                         weeks: weeks,
                         months: months,
                         years: years)
    }
}

//MARK: - Load Current Theme
func loadAppTheme(withEmail email: String, view: UIView){
    let db = Firestore.firestore()
    db.collection(Utils.FStore.collectionName).whereField(Utils.FStore.themeOwner, isEqualTo: email).getDocuments { (querySnapshot, error) in
        if let e = error{
            print("There was an issue with retrieving current theme, \(e)")
        }else{
            if let snapshotDocuments = querySnapshot?.documents{
                let data = snapshotDocuments.first?.data()
                if let selectedTheme = data?[Utils.FStore.selectedTheme] as? String{
                    DispatchQueue.main.async {
                        Theme.current = Utils.themes[selectedTheme]!
                        view.backgroundColor = Theme.current.background
                    }
                }
            }
        }
    }
}

//MARK: - Instruction Pop-up Dialog
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
        
        let understandButton = DefaultButton(title: "Start", dismissOnTap: true) {}
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
                                                print("There was an issue saving reuslts-instruction property to firestore, \(e)")
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



//MARK: - configure flashcard
func configureFlashCard(flashCard: FlashCardView, front: UIView, back: UIView){
    flashCard.duration = 2.0
    flashCard.flipAnimation = .flipFromLeft
    flashCard.frontView = front
    flashCard.backView = back
    flashCard.layer.cornerRadius = 25
}

//MARK: - Keyboard Handling
extension UIViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


//MARK: - SignIn/Reg TextField
extension UITextField {
    func configure(color: UIColor = .blue,
                   font: UIFont = UIFont.boldSystemFont(ofSize: 12),
                   cornerRadius: CGFloat,
                   borderColor: UIColor? = nil,
                   backgroundColor: UIColor,
                   borderWidth: CGFloat? = nil) {
        if let borderWidth = borderWidth {
            self.layer.borderWidth = borderWidth
        }
        if let borderColor = borderColor {
            self.layer.borderColor = borderColor.cgColor
        }
        self.layer.cornerRadius = cornerRadius
        self.font = font
        self.textColor = color
        self.backgroundColor = backgroundColor
    }
}

class SignInRegTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
