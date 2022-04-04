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
    

    private let callbackURLScheme = "awesomenotes"
    
    private let presentationContextProvider = WebAuthenticationPresentationContextProvider()
    
    
    
    func processAuthentification(url tokenRequestUrl: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let authenticationSession =
            ASWebAuthenticationSession(url: tokenRequestUrl, callbackURLScheme: callbackURLScheme) { callbackURL, error in
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
