//
//  YandexDiskManager.swift
//  NotesApp
//
//  Created by Сашок on 05.04.2022.
//

import Foundation
import CoreData
import Alamofire

class YandexDiskManager {
    static let shared = YandexDiskManager()
    
    private lazy var backedSerialQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    private lazy var backednConcurrentQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        
        return queue
    }()
    
    var accessToken: String? {
        YandexDiskTokenProvider.shared.getAuthToken()
    }
    
    private init() {}
    
    func saveNote(_ noteMO: NoteMO) {
        guard accessToken != nil, let note = noteMO.toModel() else {
            return
        }
        backedSerialQueue.addOperation(SaveNoteOperation(note: note))
    }
    
    func saveNotes(_ notes: [NoteMO]) {
        guard accessToken != nil else {
            return
        }
        
        for note in notes {
            saveNote(note)
        }
    }
    
    func deleteNote(_ noteMO: NoteMO) {
        guard accessToken != nil, let id = noteMO.id else {
            return
        }
        backedSerialQueue.addOperation(DeleteNoteOperation(id: id))
    }
    
    func deleteNotes(_ notes: [NoteMO]) {
        guard accessToken != nil else {
            return
        }
        
        for note in notes {
            deleteNote(note)
        }
    }
    
    func performSync() {
        guard accessToken != nil else {
            return
        }
        
        let loadNotesListOperation = LoadNotesListOperation()
        let uploadOperation = UploadMissingNotesOperation()
        
        let adapterOperation = BlockOperation { [unowned loadNotesListOperation, unowned uploadOperation] in
            uploadOperation.result = loadNotesListOperation.result
        }
        
        let finishOperation = BlockOperation { }
        
        let schedulerOperation = BlockOperation { [unowned loadNotesListOperation, unowned finishOperation] in
            guard let notesList = loadNotesListOperation.result else {
                return
            }
            
            let ids = notesList.map { UUID(uuidString: ($0.name as NSString).deletingPathExtension) }.compactMap { $0 }
            
            for id in ids {
                let downloadOperation = BlockOperation() { }
                finishOperation.addDependency(downloadOperation)
                
                self.backednConcurrentQueue.addOperation(downloadOperation)
            }
        }
        
        adapterOperation.addDependency(loadNotesListOperation)
        uploadOperation.addDependency(adapterOperation)
        
        schedulerOperation.addDependency(loadNotesListOperation)
        finishOperation.addDependency(schedulerOperation)
        
//        let syncOperation = BlockOperation { [unowned loadNotesListOperation] in
//
//            guard let notesList = loadNotesListOperation.result else {
//                return
//            }
//
//
//            var ids = [UUID]()
//
//            for resource in notesList {
//                let name = (resource.name as NSString).deletingPathExtension
//                if let id = UUID(uuidString: name) {
//                    ids.append(id)
//                }
//            }
//
//            let backgroundContext =
//                CoreDataStackHolder.shared.persistentContainer.newBackgroundContext()
//            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//
//            backgroundContext.performAndWait {
//                let fetchRequest = NoteMO.fetchRequest()
//                fetchRequest.predicate = NSPredicate(format: "NOT(id IN %@)", ids)
//
//                if let notes = try? backgroundContext.fetch(fetchRequest) {
//                    for note in notes {
//                        YandexDiskManager.shared.saveNote(note)
//                    }
//                }
//            }
//
//
//
//
//
//
//
//            for id in ids {
//                let downloadOperation = BlockOperation() {
//                    // completion block
//                    let note = NoteMO(context: backgroundContext)
//                    backgroundContext.trySave()
//                }
//
//            }
//
//            let downloadNotesOperation = BlockOperation {}
//
//
//            backgroundContext.performAndWait {
//                let fetchRequest = NoteMO.fetchRequest()
//                fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
//            }
//
//        }
//        syncOperation.addDependency(loadNotesListOperation)
//
//
//
//
//
//        backednConcurrentQueue.addOperations([loadNotesListOperation, syncOperation], waitUntilFinished: false)
//
//
//
////        let backgroundContext =
////            CoreDataStackHolder.shared.persistentContainer.newBackgroundContext()
////        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
////
////        backgroundContext.performAndWait {
////            let fetchRequest = NoteMO.fetchRequest()
////            let notes = try? backgroundContext.fetch(fetchRequest)
////
////            let newNote = NoteMO(context: backgroundContext)
////            newNote.id = UUID(uuidString: "84208F50-F135-4855-8621-B3BF5EA87AAE")
////            newNote.title = "Fixed title"
////            newNote.content = ""
////            newNote.date = Date()
////
////            backgroundContext.trySave()
////
////            print(notes?.count)
////        }
    }

}

class UploadMissingNotesOperation: AsyncOperation {
    var result: [Resource]?
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let backgroundContext =
            CoreDataStackHolder.shared.persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return backgroundContext
    }()
    

    override func main() {
        guard let notesList = result else {
            finish()
            return
        }
        
        let ids = notesList.map { UUID(uuidString: ($0.name as NSString).deletingPathExtension) }.compactMap { $0 }
        
        backgroundContext.performAndWait {
            let fetchRequest = NoteMO.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "NOT(id IN %@)", ids)
            
            if let notes = try? backgroundContext.fetch(fetchRequest) {
                YandexDiskManager.shared.saveNotes(notes)
            }
        }
        
        finish()
    }
}


class YandexDiskManagerGCD {
    static let shared = YandexDiskManagerGCD()
    
    private init() {}

    private func getUpdateContext() -> NSManagedObjectContext {
        let backgroundContext =
            CoreDataStackHolder.shared.persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return backgroundContext
    }
    
    
    private let backendSerialQueue = DispatchQueue(label: "myquwue", qos: .utility)
//    private let backendConcurrentQueue = DispatchQueue(label: "concurrentQueue", qos: .utility, attributes: [.concurrent])
    private let semaphore = DispatchSemaphore(value: 1)
    
    var accessToken: String? {
        YandexDiskTokenProvider.shared.getAuthToken()
    }
    
    let baseUrl = "https://cloud-api.yandex.net/v1/disk/resources"
}

// MARK: delete note
extension YandexDiskManagerGCD {
    func deleteNote(_ noteMO: NoteMO) {
        guard accessToken != nil, let id = noteMO.id else {
            return
        }
        
        backendSerialQueue.async {
            self.semaphore.wait()
            self.deleteNote(id: id) { result in
                print("delete end")
                self.semaphore.signal()
                print(result)
            }
        }
    }
    
    private func deleteNote(id: UUID, completion: @escaping (Result<Data?, AFError>) -> Void) {
        guard let token = accessToken else {
            completion(.failure(.explicitlyCancelled))
            return
        }

        let headers: HTTPHeaders = [
            "Authorization": "OAuth \(token)",
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            "path" : "app:/\(id).json",
            "permanently": true
        ]
        
        AF.request(baseUrl, method: .delete, parameters: parameters, headers: headers)
            .validate()
            .response(queue: DispatchQueue.global()) { dataResponse in
                completion(dataResponse.result)
            }
    }
}


// MARK:  - save note to yandex disk
extension YandexDiskManagerGCD {
    
    func saveNote(_ noteMO: NoteMO) {
        guard accessToken != nil, let note = noteMO.toModel() else {
            return
        }
        
        backendSerialQueue.async {
            self.semaphore.wait()
            self.saveNote(note: note) { result in
                self.semaphore.signal()
                print(result)
                
            }
        }
    }
    
    private func saveNote(note: Note, completion: @escaping (Result<Data?, AFError>) -> Void) {
        guard accessToken != nil else {
            completion(.failure(.explicitlyCancelled))
            return
        }

        getUploadUrl(note: note) { result in
            switch result {
            case .success(let response):
                guard let url = URL(string: response.href) else {
                    completion(.failure(.explicitlyCancelled))
                    return
                }
                self.uploadNote(note: note, to: url, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getUploadUrl(note: Note, completion: @escaping (Result<UrlResponse, AFError>) -> Void) {
        guard let token = accessToken else {
            completion(.failure(.explicitlyCancelled))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "OAuth \(token)",
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            "path" : "app:/\(note.id).json",
            "overwrite": true
        ]
        
        AF.request("\(baseUrl)/upload", parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: UrlResponse.self, queue: DispatchQueue.global()) { dataResponse in
                completion(dataResponse.result)
            }
    }
    
    private func uploadNote(note: Note, to url: URL, completion: @escaping (Result<Data?, AFError>) -> Void) {
        AF.request(url, method: .put, parameters: note, encoder: JSONParameterEncoder.default)
            .validate()
            .response(queue: DispatchQueue.global()) { dataResponse in
                completion(dataResponse.result)
            }
    }
}

extension YandexDiskManagerGCD {
    
    private func downloadNote(id: UUID, completion: @escaping (Result<Note, AFError>) -> Void) {
        guard accessToken != nil else {
            completion(.failure(.explicitlyCancelled))
            return
        }

        getDownloadUrl(id: id) { result in
            switch result {
            case .success(let response):
                guard let url = URL(string: response.href) else {
                    completion(.failure(.explicitlyCancelled))
                    return
                }
                self.downloadNote(from: url, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getDownloadUrl(id: UUID, completion: @escaping (Result<UrlResponse, AFError>) -> Void) {
        guard let token = accessToken else {
            completion(.failure(.explicitlyCancelled))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "OAuth \(token)",
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            "path" : "app:/\(id).json"
        ]
        
        AF.request("\(baseUrl)/download", parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: UrlResponse.self, queue: DispatchQueue.global()) { dataResponse in
                completion(dataResponse.result)
            }
    }
    
    private func downloadNote(from url: URL, completion: @escaping (Result<Note, AFError>) -> Void) {
        AF.request(url)
            .validate()
            .responseDecodable(of: Note.self, queue: DispatchQueue.global()) { response in
                completion(response.result)
            }
    }
    
    private func downloadNotes(with ids: [UUID],
                               noteDownloadConmpletion: @escaping (Result<Note, AFError>) -> Void,
                               completion: (() -> Void)? = nil) {
        
        let group = DispatchGroup()
        
        
        for id in ids {
            group.enter()
            self.downloadNote(id: id) { result in
                noteDownloadConmpletion(result)
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.global()) {
            completion?()
        }
    }
}


extension YandexDiskManagerGCD {
    func syncData(completion: (() -> Void)? = nil) {
        guard accessToken != nil else {
            completion?()
            return
        }
        
        getAppCatalogInfo { result in
            switch result {
            case .success(let response):
                let backgroundContext = self.getUpdateContext()
                
                let ids =
                    response._embedded.items.map { UUID(uuidString: ($0.name as NSString).deletingPathExtension) }.compactMap { $0 }
                
                self.uploadMissingNotes(ids: ids, in: backgroundContext)
                
                self.downloadNotes(with: ids) { result in
                    
                    
                    switch result {
                    case .success(let note):
                        print("download finish \(note.title)")
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
    
    
    private func getAppCatalogInfo(completion: @escaping (Result<GetCatlogMetaInfoResponse, AFError>) -> Void) {
        guard let token = accessToken else {
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "OAuth \(token)",
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            "path" : "app:/",
            "overwrite": true
        ]
        
        AF.request("\(baseUrl)", parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: GetCatlogMetaInfoResponse.self, queue: DispatchQueue.global()) { dataResponse in
                completion(dataResponse.result)
            }
    }
    
    private func uploadMissingNotes(ids: [UUID], in context: NSManagedObjectContext) {
        context.perform {
            let fetchRequest = NoteMO.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "NOT(id IN %@)", ids)
            
            if let notes = try? context.fetch(fetchRequest) {
                for note in notes {
                    YandexDiskManagerGCD.shared.saveNote(note)
                }
            }
        }
    }
    
}
