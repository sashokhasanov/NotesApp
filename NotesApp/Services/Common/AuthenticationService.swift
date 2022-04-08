//
//  AuthenticationService.swift
//  NotesApp
//
//  Created by Сашок on 01.04.2022.
//

import AuthenticationServices

class WebAuthenticationPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes.compactMap {
            ($0 as? UIWindowScene)?.windows.filter { $0.isKeyWindow }.first }.first ?? ASPresentationAnchor()
    }
}

class AuthenticationService {
    static let shared = AuthenticationService()
    
    private let callbackURLScheme = "awesomenotes"
    private let presentationContextProvider = WebAuthenticationPresentationContextProvider()
    
    func processAuthentication(url tokenRequestUrl: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let authenticationSession =
            ASWebAuthenticationSession(url: tokenRequestUrl, callbackURLScheme: callbackURLScheme) { callbackURL, error in
            if let error = error {
                completion(.failure(error))
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
