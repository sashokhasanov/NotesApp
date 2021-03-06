//
//  YandexDiskAuthenticationService.swift
//  NotesApp
//
//  Created by Сашок on 04.04.2022.
//

import Foundation

class YandexDiskAuthenticationService {
    static let shared = YandexDiskAuthenticationService()
    
    private let authorizationUrl = "https://oauth.yandex.ru/authorize"

    private lazy var clientId: String = {
        
        guard let filePath = Bundle.main.path(forResource: "YandexDiskApp-Info", ofType: "plist") else {
            fatalError("Couldn't find file 'YandexDiskApp-Info.plist'.")
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "CLIENT_ID") as? String else {
            fatalError("Couldn't find key 'CLIENT_ID' in 'YandexDiskApp-Info.plist'.")
        }
        
        if (value.starts(with: "_")) {
            fatalError("Provide client id for App registered at https://oauth.yandex.ru/")
        }
            
        return value
    }()
    
    private var tokenRequestUrl: URL? {
        guard var urlComponents = URLComponents(string: authorizationUrl) else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "client_id", value: clientId)
        ]
        
        return urlComponents.url
    }
    
    private init() {}
    
    func processAuthentication(completion: @escaping (Result<String, Error>) -> Void) {
        guard let tokenRequestUrl = tokenRequestUrl else {
            return
        }

        AuthenticationService.shared.processAuthentication(url: tokenRequestUrl) { result in
            switch result {
            case .success(let url):
                completion(self.parseCallbackUrl(url: url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func parseCallbackUrl(url: URL) -> Result<String, Error> {
        guard let fragment = url.fragment,
              let dummyURL = URL(string: "http://dummyurl.com?\(fragment)"),
              let components = URLComponents(url: dummyURL, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return .failure(YandexAuthError.noToken) }

        if let error = queryItems.first(where: { $0.name == "error" })?.value {
            if let yandexAuthError = YandexAuthError(rawValue: error) {
                return .failure(yandexAuthError)
            }
            return .failure(YandexAuthError.unknownError)
        } else if let token = queryItems.first(where: { $0.name == "access_token" })?.value {
            return .success(token)
        }
        
        return .failure(YandexAuthError.unknownError)
    }
}

extension YandexDiskAuthenticationService {
    enum YandexAuthError: String, Error {
        case noToken
        case accessDenied = "access_denied"
        case unauthorizedClient = "unauthorized_client"
        case unknownError
    }
}
