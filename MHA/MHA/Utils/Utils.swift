import UIKit
import Foundation
import DateToolsSwift
import RealmSwift
import Firebase
import FirebaseFirestore
import PopupDialog

class Utils{
    
    //MARK: - Segue Identifiers
    public static let signinUserInputSegue = "SignInToUserInput"
    public static let registerUserInputSegue = "RegisterToUserInput"
    public static let userInputCalendarSegue = "UserInputToCalendar"
    public static let calendarUserInputSegue = "CalendarToUserInput"
    public static let userInputReportSegue = "UserInputToResult"
    public static let resultStatsSegue = "ResultToStats"
    
    
    //MARK: - Month
    
    public static let monthMap = [1:"Jan", 2: "Feb", 3: "Mar", 4:"Apr",
                                  5:"May", 6:"Jun", 7:"Jul",
                                  8:"Aug", 9: "Sept", 10: "Oct", 11: "Nov", 12: "Dec"]
    
    //MARK: - Maslow Need Label
    public static let needTypeList = ["air","water","food","clothing",
                                      "shelter","sleep","reproduction",
                                      "personal_security","employment",
                                      "resources","property","health",
                                      "family","respect", "status","intimacy",
                                      "friendship","self_esteem","recognition",
                                      "strength","freedom","self_actualization", "connection"]
    
    public static let phyNeeds = ["reproduction","air","shelter","sleep","water","food","clothing"]
    public static let safetyNeeds = ["personal_security","employment",
                                     "resources","property","health"]
    public static let loveNeeds = ["friendship", "intimacy", "family", "connection"]
    public static let esteemNeeds = ["respect","self_esteem","status","recognition", "strength","freedom"]
    public static let selfActualNeeds  = ["self_actualization"]
    
    public static let phyNeedName = "Physiological"
    public static let safetyNeedName = "Safety"
    public static let loveBelongingNeedName = "Love & Belonging"
    public static let esteemNeedName = "Esteem"
    public static let selfActualNeedName = "Self-Actualization"
    
    
    //MARK: - Maslow Need Data
    public static let phyCategoryIndexMap = ["reproduction": 0, "air": 1, "shelter": 2,
                                             "sleep": 3, "water": 4, "food": 5, "clothing": 6]
    public static let safetyIndexMap = ["personal_security":0, "employment":1,
                                        "resources":2,"property":3,"health":4]
    public static let loveIndexMap = ["friendship":0, "intimacy":1, "family":2, "connection":3]
    public static let esteemIndexMap = ["respect":0,"self_esteem":1,"status":2,"recognition":3, "strength":4,"freedom":5]
    public static let selfActualIndexMap = ["self_actualization":0]
    
    
    //MARK: - Maslow Need Colours
    public static let baseColour = "#7e7474"
    public static let phyNeedColoursList = ["#E97452","#D65D42",
                                            "#C34632","#B12E21","#9E1711","#8B0001","#4B0A0E"]
    public static let safetyNeedColoursList = ["#FDB777", "#FDA766", "#FD9346", "#FD7F2C", "#FF6200"]
    public static let loveNeedColoursList = ["#FFF192", "#FFEA61", "#FFDD3C", "#FFD400"]
    public static let esteemNeedColoursList = ["#B7FFBF","#95F985","#4DED30","#26D701","#00C301", "#00AB08"]
    public static let selfActualNeedColoursList = ["#00008b"]
    public static let needColourMap = [phyNeeds: "#a20a0a", safetyNeeds: "#db6400", loveNeeds: "#ffa62b", esteemNeeds: "#03c4a1", selfActualNeeds: "#005086"]
    
    //MARK: - Calendar Event Colours
    public static let eventColours = ["#9ad3bc","#fd8c04", "#9088d4", "#f3bad6", "#9ddfd3",
                                      "#ffa36c", "#bedbbb", "#0e918c", "#a6f6f1", "#edcfa9"]
    
    
    //MARK: - Messages
    public static let saveNoteAlertMsg = "Have you saved your current note?"
    public static let resultsInstructionMsg = "1. Tap on each level tag to view activity progression.\n2. Tap inside each level to view detailed data"
    public static let activityDefaultMsg = "Please compose your activity here..."
    public static let needSelectInstructionMsg = "1. Select needs that activity has fulfilled\n 2. Click on the selected need if you want to deselect it"
    public static let pieChartTitle = "Daily Activity Overview"
    
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

//MARK: - Hex to UIColor
func hexStringToUIColor (hex:String) -> UIColor {
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

//MARK: - Populate Daily-Need & Daily-Activity Map
func loadDailyNeed(date: Date)-> DailyNeedData? {
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

func loadDailyActivityResult(date: Date)-> DailyActivityData? {
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
    static let showInstruction = "showInstruction"
    
    static func allowDisplayInstructionDialog(VC: UIViewController, message: String){
        if let currentUser = Auth.auth().currentUser?.email{
            db.collection(collectionName).whereField(settingOwner, isEqualTo: currentUser).getDocuments {(querySnapshot, error) in
                if let e = error{
                    print("Error with retrieving instruction-dialog setting, \(e)")
                }else{
                    if let snapshotDocuments = querySnapshot?.documents{
                        if snapshotDocuments.count<1{
                            PopUp.buildInstructionDialog(VC: VC, message: message)
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
                                    db.collection(collectionName).addDocument(
                                        data:[settingOwner: currentUser,
                                              showInstruction: false]) { (error) in
                                        if let e = error{
                                            print("There was an issue saving show-instruction property to firestore, \(e)")
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
        defaultButtonAppearance.buttonColor = hexStringToUIColor(hex: "#61b15a")
        
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


//MARK: - String Utils
extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...]
                .range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
