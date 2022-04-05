//
//  Note.swift
//  NotesApp
//
//  Created by Сашок on 05.04.2022.
//

import CoreData

struct Note: Codable {
    let id: UUID
    let title: String
    let content: String
    let color: Int64
    let pinned: Bool
    let date: Date
}

extension Note: MangedObjectConvertible{
    func toManagedObject(context: NSManagedObjectContext) -> NoteMO {
        let note = NoteMO(context: context)
        note.id = id
        note.title = title
        note.content = content
        note.color = color
        note.pinned = pinned
        note.date = date
        
        return note
    }
}
