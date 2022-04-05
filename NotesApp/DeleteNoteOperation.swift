//
//  DeleteNoteOperation.swift
//  NotesApp
//
//  Created by Сашок on 05.04.2022.
//

import Alamofire
import Foundation

class DeleteNoteOperation: YandexDiskBasicOperation {
    private let id: UUID
    
    init(id: UUID) {
        self.id = id
        super.init()
    }
    
    override func main() {
        guard let token = accessToken else {
            finish()
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
                if let error = dataResponse.error {
                    print(error)
                }
                
                self.finish()
            }
    }
}
