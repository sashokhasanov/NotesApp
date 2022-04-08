//
//  YandexDiskManager.swift
//  NotesApp
//
//  Created by Сашок on 05.04.2022.
//

import CoreData
import Alamofire

class YandexDiskManager {
    static let shared = YandexDiskManager()
    
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
extension YandexDiskManager {
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
extension YandexDiskManager {
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
extension YandexDiskManager {
    func downloadNotes(with ids: [UUID],
                               noteDownloadConmpletion: @escaping (Result<Note, AFError>) -> Void,
                               completion: (() -> Void)? = nil) {
        
        let group = DispatchGroup()
        
        for id in ids {
            group.enter()
            self.downloadNote(with: id) { result in
                noteDownloadConmpletion(result)
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.global()) {
            completion?()
        }
    }
    
    func downloadNote(with id: UUID, completion: @escaping (Result<Note, AFError>) -> Void) {
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
    
    
}
extension YandexDiskManager {
    func getAppCatalogInfo(completion: @escaping (Result<Resource, AFError>) -> Void) {
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
}

// MARK: - Common code
extension YandexDiskManager {
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
