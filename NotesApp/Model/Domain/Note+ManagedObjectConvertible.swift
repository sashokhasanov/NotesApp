//
//  Note+ManagedObjectConvertible.swift
//  NotesApp
//
//  Created by Сашок on 08.04.2022.
//

import CoreData

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
