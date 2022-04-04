//
//  WebAuthenticationPresentationContextProvider.swift
//  NotesApp
//
//  Created by Сашок on 04.04.2022.
//

import Foundation
import AuthenticationServices

class WebAuthenticationPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes.compactMap {
            ($0 as? UIWindowScene)?.windows.filter { $0.isKeyWindow }.first }.first ?? ASPresentationAnchor()
    }
}
