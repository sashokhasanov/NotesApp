//
//  NotesProvider.swift
//  NotesApp
//
//  Created by Сашок on 28.03.2022.
//

import Foundation
import CoreData

class NotesProvider {
    private(set) var persistentContainer: NSPersistentContainer
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    private(set) lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        let fetchRequest = Note.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate
        
        do {
            try controller.performFetch()
        } catch {
            fatalError("\(#function): Failed to performFetch: \(error)")
        }
        
        return controller
    }()
    
    init(persistentContainer: NSPersistentContainer,
         fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?) {
        self.persistentContainer = persistentContainer
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }
    
    func addNote(in context: NSManagedObjectContext, completionHandler: ((_ newNote: Note) -> Void)? = nil) {
        context.perform {
            let note = self.createEmptyNote(in: context)
            context.trySave()
            completionHandler?(note)
        }
    }
    
    func delete(note: Note, completionHandler: (() -> Void)? = nil) {
        guard let context = note.managedObjectContext else {
            fatalError("\(#function): Failed to retrieve the context from: \(note)")
        }
        context.perform {
            context.delete(note)
            context.trySave()
            completionHandler?()
        }
    }
    
    private func createEmptyNote(in context: NSManagedObjectContext) -> Note {
        let note = Note(context: context)
        
        note.id = UUID()
        note.date = Date()
        
        return note
    }
}
