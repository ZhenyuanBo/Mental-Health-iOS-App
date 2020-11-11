import Foundation
import RealmSwift

class Need: Object{
    @objc dynamic var dateCreated: String = ""
    @objc dynamic var needResult: String = ""
    
    override static func primaryKey() -> String? {
      return "dateCreated"
    }

}
