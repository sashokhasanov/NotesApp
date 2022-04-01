//
//  AuthentificationService.swift
//  NotesApp
//
//  Created by Сашок on 01.04.2022.
//

import Foundation
import AuthenticationServices

class AuthentificationService {
    
    static let shared = AuthentificationService()
    
    private let authorizationUrl = "https://oauth.yandex.ru/authorize"
    private let clientId = "25e2a8a4c06141abbff41d2ce258343d"
    private let callbackURLScheme = "awesomenotes"
    
    private let presentationContextProvider = PresentationContextProvider()
    
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
    
    func processAuthentification(completion: @escaping (Result<URL, Error>) -> Void) {
        guard let tokenRequestUrl = tokenRequestUrl else { return }
        
        let authenticationSession = ASWebAuthenticationSession(url: tokenRequestUrl,
                                                               callbackURLScheme: callbackURLScheme) { callbackURL, error in
            if let error = error {
                completion(.failure(error))
                return
            } else if let callbackURL = callbackURL {
                completion(.success(callbackURL))
            }
        }
        
        authenticationSession.presentationContextProvider = presentationContextProvider
        authenticationSession.prefersEphemeralWebBrowserSession = true
        authenticationSession.start()
    }
    
    private init() {}
}

class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes.compactMap {
            ($0 as? UIWindowScene)?.windows.filter { $0.isKeyWindow }.first }.first ?? ASPresentationAnchor()
    }
    
    
}
