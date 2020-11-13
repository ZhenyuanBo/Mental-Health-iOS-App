import Foundation
import RealmSwift

class Activity: Object{
    @objc dynamic var activityID: String=""
    @objc dynamic var activityText: String=""
    @objc dynamic var dateCreated: String=""
    
    override static func primaryKey() -> String? {
      return "activityID"
    }
}
