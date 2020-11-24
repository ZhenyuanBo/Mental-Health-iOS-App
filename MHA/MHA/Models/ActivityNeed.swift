import Foundation
import RealmSwift

class ActivityNeed: Object{
    @objc dynamic var selectedNeeds: String = ""
    @objc dynamic var activityID: String = ""
    
    override static func primaryKey() -> String? {
      return "activityID"
    }
}
