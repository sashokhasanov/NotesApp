//
//  CoreData+Extension.swift
//  NotesApp
//
//  Created by Сашок on 28.03.2022.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func trySave() {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            guard let error = error as NSError? else { return }
            fatalError("\(#function): Failed to save context:\(error)")
        }
    }
}
