import Foundation
import RealmSwift

class HistoryNote: Object{
    @objc dynamic var subjectTitle: String = ""
    @objc dynamic var dateCreated: Date?
    let notes = List<Note>()
}
