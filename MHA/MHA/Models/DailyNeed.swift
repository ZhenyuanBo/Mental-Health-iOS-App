import Foundation
import RealmSwift

class DailyNeed: Object{
    @objc dynamic var dateCreated: String = ""
    @objc dynamic var needResult: String = ""
    
    override static func primaryKey() -> String? {
      return "dateCreated"
    }

}
