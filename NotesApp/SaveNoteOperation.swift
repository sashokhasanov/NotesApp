//
//  UploadNoteOperation.swift
//  NotesApp
//
//  Created by Сашок on 04.04.2022.
//

import Alamofire

class SaveNoteOperation: YandexDiskBasicOperation {
    private var note: Note
    
    init(note: Note) {
        self.note = note
        super.init()
    }
    
    override func main() {
        getUploadUrl(completion: uploadNote)
    }
    
    private func getUploadUrl(completion: @escaping (String) -> Void) {
        guard let token = accessToken else {
            finish()
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
            .responseDecodable(of: UploadUrlResponse.self, queue: DispatchQueue.global()) { dataResponse in
                let result = dataResponse.result
                
                switch result {
                case .success(let response):
                    completion(response.href)
                case .failure(let error):
                    print(error)
                    self.finish()
                }
            }
    }
    
    private func uploadNote(href: String) {
        AF.request(href, method: .put, parameters: note, encoder: JSONParameterEncoder.default)
            .validate()
            .response(queue: DispatchQueue.global()) { dataResponse in
                if let error = dataResponse.error {
                    print(error)
                }
                self.finish()
            }
    }
}

extension SaveNoteOperation {
    private struct UploadUrlResponse: Decodable {
        let href: String
        let method: String
    }
}
