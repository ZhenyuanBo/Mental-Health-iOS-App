import UIKit
import Foundation
import DateToolsSwift
import RealmSwift

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

    //MARK: - Maslow Need Category Data
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
    
    
    public static let phyCategoryIndexMap = ["reproduction": 0, "air": 1, "shelter": 2,
                            "sleep": 3, "water": 4, "food": 5, "clothing": 6]
    public static let safetyIndexMap = ["personal_security":0, "employment":1,
                                        "resources":2,"property":3,"health":4]
    public static let loveIndexMap = ["friendship":0, "intimacy":1, "family":2, "connection":3]
    public static let esteemIndexMap = ["respect":0,"self_esteem":1,"status":2,"recognition":3, "strength":4,"freedom":5]
    public static let selfActualIndexMap = ["self_actualization":0]
    
    
    public static let needColourMap = [phyNeeds: "#a20a0a", safetyNeeds: "#db6400", loveNeeds: "#ffa62b", esteemNeeds: "#03c4a1", selfActualNeeds: "#005086"]
    
    
    //MARK: - Maslow Hierarchy Base Colour
    
    public static let baseColour = "#7e7474"
    
    //MARK: - Maslow Need Colours
    public static let phyNeedColoursList = ["#E97452","#D65D42",
                                 "#C34632","#B12E21","#9E1711","#8B0001","#4B0A0E"]
    public static let safetyNeedColoursList = ["#FDB777", "#FDA766", "#FD9346", "#FD7F2C", "#FF6200"]
    public static let loveNeedColoursList = ["#FFF192", "#FFEA61", "#FFDD3C", "#FFD400"]
    public static let esteemNeedColoursList = ["#B7FFBF","#95F985","#4DED30","#26D701","#00C301", "#00AB08"]
    public static let selfActualNeedColoursList = ["#00008b"]
    
    //MARK: - Calendar Event Colours
    public static let eventColours = ["#9ad3bc","#fd8c04", "#9088d4", "#f3bad6", "#9ddfd3",
                           "#ffa36c", "#bedbbb", "#0e918c", "#a6f6f1", "#edcfa9"]
    
    
    //MARK: - Alert Messages
    public static let saveNoteAlertMsg = "Do you want to save current note?"
    public static let saveNoteBeforeLeavingAlertMsg = "Do you want to save current note before leaving?"
    
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


