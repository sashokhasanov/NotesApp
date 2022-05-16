//
//  NoteTableWorker.swift
//  NotesApp
//
//  Created by Сашок on 14.05.2022.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import CoreData

protocol NoteTableWorkerDelegate: AnyObject {
    func workerDidBeginDataUpdate()
    func workerDidEndDataUpdate()
    func workerDidUpdateData(indexPath: IndexPath?,
                             newIndexPath: IndexPath?,
                             updateKind: NoteTable.UpdateData.UpdateKind?)
}

class NoteTableWorker: NSObject {
    private let persistentContainer: NSPersistentContainer = CoreDataStackHolder.shared.persistentContainer
    weak var delegate: NoteTableWorkerDelegate?
    
    private(set) lazy var fetchedResultsController: NSFetchedResultsController<NoteMO> = {
        let fetchRequest = NoteMO.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pinned", ascending: false),
                                        NSSortDescriptor(key: "date", ascending: false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        
        return controller
    }()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextDidSave),
                                               name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    func fetchNotes() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("\(#function): Failed to performFetch: \(error)")
        }
    }
    
    func addNote(completion: @escaping (IndexPath?) -> Void) {
        CoreDataService.shared.addNote(in: persistentContainer.viewContext) { newNote in
            YandexDiskSynchronizatinManager.shared.uploadNote(newNote)
            
            let indexPath = self.fetchedResultsController.indexPath(forObject: newNote)
            completion(indexPath)
        }
    }

    func deleteNote(at indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)
        
        YandexDiskSynchronizatinManager.shared.deleteNote(note)
        CoreDataService.shared.delete(note: note)
    }
    
    func pinNote(at indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)
        note.pinned.toggle()
        
        YandexDiskSynchronizatinManager.shared.uploadNote(note)
        CoreDataService.shared.save(note: note)
    }
    
    func filterNotes(searchText: String) {
        var searchPredicate: NSPredicate?
        if !searchText.isEmpty {
            searchPredicate =
                NSPredicate(format: "(title contains[cd] %@) || (content contains[cd] %@)", searchText, searchText)
        }

        fetchedResultsController.fetchRequest.predicate = searchPredicate
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }

    func synchronizeData(completion: @escaping () -> Void) {
        YandexDiskSynchronizatinManager.shared.syncData {
            completion()
        }
    }
    
    func getNumberOfSections() -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections.count
    }
    
    func getNumberOfRowsInSection(_ section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    func getNote(at indexPath: IndexPath) -> NoteMO {
        fetchedResultsController.object(at: indexPath)
    }
    
    @objc private func managedObjectContextDidSave(notification: Notification) {
        let viewContext = persistentContainer.viewContext
        
        viewContext.perform {
            viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate protocol conformance
extension NoteTableWorker: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.workerDidBeginDataUpdate()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var updateKind: NoteTable.UpdateData.UpdateKind?
        
        switch type {
        case .insert:
            updateKind = .insert
        case .update:
            updateKind = .update
        case .move:
            updateKind = .move
        case .delete:
            updateKind = .delete
        @unknown default:
            break
        }

        delegate?.workerDidUpdateData(indexPath: indexPath, newIndexPath: newIndexPath, updateKind: updateKind)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.workerDidEndDataUpdate()
    }
}
