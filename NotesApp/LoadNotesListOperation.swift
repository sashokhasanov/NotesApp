//
//  LoadNotesListOperation.swift
//  NotesApp
//
//  Created by Сашок on 06.04.2022.
//

import Alamofire

class LoadNotesListOperation: YandexDiskBasicOperation {
    
    override func main() {
//        getUploadUrl(completi)
        getAppCatalogInfo()
    }
    
    var result: [Resource]?
    
    private func getAppCatalogInfo() {
        guard let token = accessToken else {
            finish()
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
                let result = dataResponse.result
                
                switch result {
                case .success(let response):
                    self.result = response._embedded.items
                    self.finish()
                case .failure(let error):
                    print(error)
                    self.finish()
                }
            }
    }
}


struct GetCatlogMetaInfoResponse: Decodable {
    let name: String
    let _embedded: ResourceList
}

struct ResourceList: Decodable {
    let items: [Resource]
}

struct Resource: Decodable {
    let name: String
    let path: String
}

