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
    
    public static let phyNeeds:Set = ["air","water","food","clothing","shelter","sleep","reproduction"]
    public static let safetyNeeds:Set = ["personal_security","employment",
                                     "resources","property","health"]
    public static let loveNeeds:Set = ["friendship", "intimacy", "family", "connection"]
    public static let esteemNeeds:Set = ["respect","self_esteem","status","recognition", "strength","freedom"]
    public static let selfActualNeeds:Set = ["self_actualization"]
    
    public static let needColourMap = [phyNeeds: "#a20a0a", safetyNeeds: "#db6400", loveNeeds: "#ffa62b", esteemNeeds: "#03c4a1", selfActualNeeds: "#005086"]
    
    
    //MARK: - Maslow Hierarchy Base Colour
    
    public static let baseColour = "#7e7474"
    
    //MARK: - Physiological Need Colours
    public static let phyNeedColoursList = ["#E97452","#D65D42",
                                 "#C34632","#B12E21","#9E1711","#8B0001","#4B0A0E"]
    
    public static let safetyOrange1 = "#FDB777"
    public static let safetyOrange5 = "#FF6200"
    
    
    
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
    
    func getDate(dateStr: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: dateStr) // replace Date String
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

//MARK: - Populate Need-Selection & Need-Activity Map
func loadNeedSelectionMap(date: Date, activityID: String? = nil)-> NeedData? {
    let realm = try! Realm()
    var selectedNeed:Results<Need>
    if let safeActivityID = activityID{
        selectedNeed = realm.objects(Need.self).filter("activityID = '\(safeActivityID)'")
    }else{
        let currDate = date.dateFormatter(format: "yyyy-MM-dd")
        selectedNeed = realm.objects(Need.self).filter("dateCreated = '\(currDate)'")
    }
    if selectedNeed.count > 0{
        let selectedNeedResult = selectedNeed[0].needResult
        let jsonData = selectedNeedResult.data(using: .utf8)!
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(NeedData.self, from: jsonData)
            return decodedData
        }catch{
            print("Fail to decode need-selection data, \(error)")
        }
    }
    return nil
}

func loadNeedActivityResult(date: Date)-> NeedActivityData? {
    let realm = try! Realm()
    let currDate = date.dateFormatter(format: "yyyy-MM-dd")
    let selectedNeedActivity = realm.objects(NeedActivity.self).filter("dateCreated = '\(currDate)'")
    if selectedNeedActivity.count > 0{
        let selectedNeedResult = selectedNeedActivity[0].numActivityResult
        let jsonData = selectedNeedResult.data(using: .utf8)!
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(NeedActivityData.self, from: jsonData)
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
