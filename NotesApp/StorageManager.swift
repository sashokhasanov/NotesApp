//
//  StorageManager.swift
//  NotesApp
//
//  Created by Сашок on 27.03.2022.
//

import Foundation
import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {}
    
    func fetchData(completion: @escaping (Result<[Note], Error>) -> Void) {
        let fetchRequest = Note.fetchRequest()
        do {
            let taskList = try viewContext.fetch(fetchRequest)
            completion(.success(taskList))
        } catch {
            completion(.failure(error))
        }
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
