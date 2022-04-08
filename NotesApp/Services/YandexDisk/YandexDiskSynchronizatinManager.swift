//
//  YandexDiskSynchronizatinManager.swift
//  NotesApp
//
//  Created by Сашок on 08.04.2022.
//

import CoreData

class YandexDiskSynchronizatinManager {
    static let shared = YandexDiskSynchronizatinManager()
    
    private var accessToken: String? {
        YandexDiskTokenProvider.shared.getAuthToken()
    }
    
    private init() {}
    
    func syncData(completion: (() -> Void)? = nil) {
        guard accessToken != nil else {
            completion?()
            return
        }
        
        YandexDiskManagerGCD.shared.getAppCatalogInfo { result in
            switch result {
            case .success(let response):
                let backgroundContext = self.getUpdateContext()
                
                let ids =
                    response._embedded?.items
                        .map { UUID(uuidString: ($0.name as NSString).deletingPathExtension) }.compactMap { $0 } ?? []
                
                self.scheduleUploadMissingNotes(ids: ids, in: backgroundContext)
                
                YandexDiskManagerGCD.shared.downloadNotes(with: ids) { result in
                    switch result {
                    case .success(let note):
                        backgroundContext.perform {
                            let _ = note.toManagedObject(context: backgroundContext)
                            backgroundContext.trySave()
                        }
                    case .failure(let error):
                        print(error)
                    }
                } completion: {
                    completion?()
                }

            case .failure(let error):
                print(error)
                completion?()
            }
        }
    }

    private func scheduleUploadMissingNotes(ids: [UUID], in context: NSManagedObjectContext) {
        context.perform {
            let fetchRequest = NoteMO.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "NOT(id IN %@)", ids)
            
            if let notes = try? context.fetch(fetchRequest) {
                for note in notes {
                    YandexDiskManagerGCD.shared.uploadNote(note)
                }
            }
        }
    }
    
    private func getUpdateContext() -> NSManagedObjectContext {
        let backgroundContext =
            CoreDataStackHolder.shared.persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return backgroundContext
    }
}
