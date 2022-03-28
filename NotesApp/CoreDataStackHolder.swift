//
//  StorageService.swift
//  NotesApp
//
//  Created by Сашок on 28.03.2022.
//

import Foundation
import CoreData

class CoreDataStackHolder {
    static let shared = CoreDataStackHolder()
    
    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            guard let error = error as NSError? else { return }
            fatalError("\(#function): Failed to load persistent stores:\(error)")
        }
        return container
    }()

    private init() {}
}
