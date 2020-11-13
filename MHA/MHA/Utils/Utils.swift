import UIKit
import Foundation
import RealmSwift

class Utils{
    
    //MARK: - Segue Identifiers
    public static let signinSegue = "SigninToHistory"
    public static let registerSegue = "RegisterToHistory"
    public static let dailyNotesSegue = "CalendarToDailyNotes"
    public static let userInputSegue = "NotesToUserInput"
    public static let notesDetailsSegue = "DailyNotesToDetails"
    
    //MARK: - Reusable Cell Identifiers
    public static let weekCell = "WeekCell"
    public static let monthCell = "MonthCell"
    public static let dayCell = "ReusableDayCell"
    public static let activityCell = "ActivityCell"
    
    //MARK: - Bar Item Button Actions
    public static let addNoteMsg = "Add New Note"
    public static let alertAddAction = "Add"
    public static let cellNibName = "NoteActivityCell"
    
    //MARK: - Screen Scroll Direction
    public static let downDirection = "down"
    public static let upDirection = "up"
    
    //MARK: - WEEK & Month
    public static let weekDayMap = [ 1:"Sun", 2:"Mon", 3:"Tue", 4:"Wed", 5:"Thur", 6:"Fri", 7:"Sat" ]
    
    public static let monthMap = [1:"Jan", 2: "Feb", 3: "Mar", 4:"Apr",
                                  5:"May", 6:"Jun", 7:"Jul",
                                  8:"Aug", 9: "Sept", 10: "Oct", 11: "Nov", 12: "Dec"]
    
    public static let monthColourMap = ["Jan": "006EAC", "Feb":"E1E0E5",
                                        "Mar":"61D200", "Apr": "4CB0B2",
                                        "May":"F4736E", "Jun":"FFA800",
                                        "Jul":"FFFFFF", "Aug":"BA9389",
                                        "Sept":"CAA301", "Oct":"F45F22",
                                        "Nov":"DCAF9F", "Dec":"949BA5"]
    
    public static let monthDayMap = ["Jan": 31, "Feb": 28, "Mar": 31, "Apr": 30,
                                    "May": 31, "Jun": 30, "Jul": 31, "Aug": 31,
                                    "Sept": 30, "Oct": 31, "Nov": 30, "Dec": 31]
    
    public static let weekDayColourMap = [0: "#389393", 1:"#fa7f72", 2: "#f5a25d",
                                          3: "#c56183", 4:"#51adcf", 5: "#892cdc",
                                          6: "#a8dda8"]
    
    //MARK: - Maslow Need Data
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
    
    
}


//MARK: - Calendar Cell
enum CellType: String{
    case week
    case month
}

enum CellContent{
    case weekRange(String, String, Date, Date)
    case monthImg(UIImage)
}


//MARK: - Date Extension

extension Date {
    
    func firstDayOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year,.month], from: self)
        guard let date = calendar.date(from: components) else {
            fatalError("First day of month doesn't exist!")
        }
        return date
    }
    
    func lastDayOfMonth() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        guard let date = calendar.date(byAdding: components, to: self.firstDayOfMonth()) else {
            fatalError("Last day of month doesn't exist!")
        }
        return date
    }
    
    func firstDayOfWeek() -> Date {
        let calendar = Calendar(identifier: .iso8601)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        guard let date = calendar.date(from: components) else {
            fatalError("First day of week doesn't exist!")
        }
        return date
    }
    
    func lastDayOfWeek() -> Date {
        let calendar = Calendar(identifier: .iso8601)
        var components = DateComponents()
        components.weekOfYear = 1
        components.day = -1
        guard let date = calendar.date(byAdding: components, to: self.firstDayOfWeek()) else {
            fatalError("Last day of week doesn't exist!")
        }
        return date
    }
    
    func daysOffset(by: Int) -> Date {
        return Date(timeInterval: Double(by * 24 * 60 * 60), since: self)
    }
    
    func numOfDaysInMonth() -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: self)
        guard let count = range?.count else {
            fatalError("Number of month doesn't exist!")
        }
        return count
    }
    
    func dateFormatter(format: String) -> String {
        let f = DateFormatter()
        f.timeZone = .autoupdatingCurrent
        f.dateFormat = format
        return f.string(from: self)
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


//MARK: - CHECK LEAP YEAR

func isLeapYear(datum: Date) -> Bool {
    let calendar = Calendar(identifier: .gregorian)
    let dateComponents = DateComponents(year: Int(calendar.component(.year, from: datum)), month: 2)
    let date = calendar.date(from: dateComponents)!
    let range = calendar.range(of: .day, in: .month, for: date)!
    let numDays = range.count
    
    if numDays == 29 {
        return true
    }else {
        return false
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

//MARK: - Populate Need-Selection & Need-Activity Map
func loadNeedSelectionMap(date: Date)-> NeedData? {
    let realm = try! Realm()
    let currDate = date.dateFormatter(format: "yyyy-MM-dd")
    let selectedNeed = realm.objects(Need.self).filter("dateCreated = '\(currDate)'")
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

