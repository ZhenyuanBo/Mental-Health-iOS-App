//
//  File.swift
//  MHA
//
//  Created by Zhenyuan Bo on 2020-11-03.
//

import Foundation
import RealmSwift

class HistoryNote: Object{
    @objc dynamic var subjectTitle: String = ""
    @objc dynamic var dateCreated: Date?
    let notes = List<Note>()
}
