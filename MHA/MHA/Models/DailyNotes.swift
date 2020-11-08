import Foundation
import RealmSwift

class DailyNotes: Object{
    @objc dynamic var date: String = ""
    let activities = List<Activity>() //forward relationship
}
