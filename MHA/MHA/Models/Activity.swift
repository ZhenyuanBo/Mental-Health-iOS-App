import Foundation
import RealmSwift

class Activity: Object{
    @objc dynamic var activityName: String=""
    @objc dynamic var dailyNoteSectionIndex: Int=0
    var parentCategory = LinkingObjects(fromType: DailyNotes.self, property: "activities")
}
