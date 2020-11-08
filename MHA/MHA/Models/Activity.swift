import Foundation
import RealmSwift

class Activity: Object{
    @objc dynamic var activityName: String=""
    var parentCategory = LinkingObjects(fromType: DailyNotes.self, property: "activities")
}
