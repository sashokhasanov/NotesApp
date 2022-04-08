//
//  YandexDiskManager.swift
//  NotesApp
//
//  Created by Сашок on 05.04.2022.
//

import CoreData
import Alamofire

class YandexDiskManagerGCD {
    static let shared = YandexDiskManagerGCD()
    
    private let baseUrl = "https://cloud-api.yandex.net/v1/disk/resources"

    private let backendSerialQueue =
        DispatchQueue(label: (Bundle.main.bundleIdentifier ?? "ru.awesome.NotesApp").appending(".backendSeriaQueue"), qos: .utility)
    private let semaphore = DispatchSemaphore(value: 1)
    
    private var accessToken: String? {
        YandexDiskTokenProvider.shared.getAuthToken()
    }
    
    private init() {}
}

// MARK: - Delete
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

// MARK:  - Save
extension YandexDiskManagerGCD {
    func uploadNote(_ noteMO: NoteMO) {
        guard accessToken != nil, let note = noteMO.toModel() else {
            return
        }
        
        backendSerialQueue.async {
            self.semaphore.wait()
            self.uploadNote(note: note) { result in
                self.semaphore.signal()
                print(result)
                
            }
        }
    }
    
    private func uploadNote(note: Note, completion: @escaping (Result<Data?, AFError>) -> Void) {
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
        getUrl(of: "\(note.id).json", for: .upload, completion: completion)
    }

    private func uploadNote(note: Note, to url: URL, completion: @escaping (Result<Data?, AFError>) -> Void) {
        AF.request(url, method: .put, parameters: note, encoder: JSONParameterEncoder.default)
            .validate()
            .response(queue: DispatchQueue.global()) { dataResponse in
                completion(dataResponse.result)
            }
    }
}

// MARK: - Download
extension YandexDiskManagerGCD {
    func downloadNote(_ noteMO: NoteMO, completion: @escaping (Result<Note, AFError>) -> Void) {
        guard accessToken != nil, let id = noteMO.id else {
            return
        }
        
        downloadNote(id: id, completion: completion)
    }
    
    private func downloadNote(id: UUID, completion: @escaping (Result<Note, AFError>) -> Void) {
        guard accessToken != nil else {
            completion(.failure(.explicitlyCancelled))
            return
        }

        getDownloadUrl(for: id) { result in
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
    
    private func getDownloadUrl(for noteId: UUID, completion: @escaping (Result<UrlResponse, AFError>) -> Void) {
        getUrl(of: "\(noteId).json", for: .download, completion: completion)
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
    private func getUpdateContext() -> NSManagedObjectContext {
        let backgroundContext =
            CoreDataStackHolder.shared.persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return backgroundContext
    }
    
    
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
                    response._embedded?.items
                        .map { UUID(uuidString: ($0.name as NSString).deletingPathExtension) }.compactMap { $0 } ?? []
                
                self.uploadMissingNotes(ids: ids, in: backgroundContext)
                
                self.downloadNotes(with: ids) { result in
                    
                    
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
    
    
    private func getAppCatalogInfo(completion: @escaping (Result<Resource, AFError>) -> Void) {
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
            .responseDecodable(of: Resource.self, queue: DispatchQueue.global()) { dataResponse in
                completion(dataResponse.result)
            }
    }
    
    private func uploadMissingNotes(ids: [UUID], in context: NSManagedObjectContext) {
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
}

// MARK: - Common code
extension YandexDiskManagerGCD {
    private enum NoteOperation: String {
        case upload
        case download
    }
    
    private func getUrl(of noteName: String, for operation: NoteOperation, completion: @escaping (Result<UrlResponse, AFError>) -> Void) {
        guard let token = accessToken else {
            completion(.failure(.explicitlyCancelled))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "OAuth \(token)",
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            "path" : "app:/\(noteName)"
        ]
        
        AF.request("\(baseUrl)/\(operation.rawValue)", parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: UrlResponse.self, queue: DispatchQueue.global()) { dataResponse in
                completion(dataResponse.result)
            }
    }
}
