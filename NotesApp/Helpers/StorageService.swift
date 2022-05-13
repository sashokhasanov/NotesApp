//
//  StorageService.swift
//  NotesApp
//
//  Created by Сашок on 13.05.2022.
//

import Foundation
import CoreData

class StorageService {
    
    static let shared = StorageService()
    
    func addNote(in context: NSManagedObjectContext, completionHandler: ((_ newNote: NoteMO) -> Void)? = nil) {
        context.perform {
            let note = self.createEmptyNote(in: context)
            context.trySave()
            completionHandler?(note)
        }
    }
    
    func save(note: NoteMO, completionHandler: (() -> Void)? = nil) {
        guard let context = note.managedObjectContext else {
            fatalError("\(#function): Failed to retrieve the context from: \(note)")
        }
        
        context.perform {
            context.trySave()
            completionHandler?()
        }
    }
    
    func delete(note: NoteMO, completionHandler: (() -> Void)? = nil) {
        guard let context = note.managedObjectContext else {
            fatalError("\(#function): Failed to retrieve the context from: \(note)")
        }
        context.perform {
            context.delete(note)
            context.trySave()
            completionHandler?()
        }
    }
    
    
    private func createEmptyNote(in context: NSManagedObjectContext) -> NoteMO {
        let note = NoteMO(context: context)
        
        note.id = UUID()
        note.date = Date()
        note.pinned = false
        
        return note
    }
    
    private init() {}
}
