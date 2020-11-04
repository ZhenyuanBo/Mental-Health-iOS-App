//
//  Notes.swift
//  MHA
//
//  Created by Zhenyuan Bo on 2020-11-03.
//

import Foundation
import RealmSwift

class Note: Object{
    @objc dynamic var notesTitle: String = ""
    @objc dynamic var notesBody: String = ""
    var parentHistoryNote = LinkingObjects(fromType: HistoryNote.self, property: "notes")
}
