import Foundation
import RealmSwift

class DailyActivity: Object{
    @objc dynamic var dateCreated: String = ""
    @objc dynamic var numActivityResult: String = ""
    
    override static func primaryKey() -> String? {
      return "dateCreated"
    }
}
