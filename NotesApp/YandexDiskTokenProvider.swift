//
//  YandexDiskTokenProvider.swift
//  NotesApp
//
//  Created by Сашок on 02.04.2022.
//

import Foundation

class YandexDiskTokenProvider {
    static let shared = YandexDiskTokenProvider()
    private let account = "YandexDisk"
    
    private init() {}
    
    func getAuthToken() -> String? {
        guard let tokenData = KeyChainService.shared.get(account: account) else {
            return nil
        }
        return String(data: tokenData, encoding: .utf8)
    }
    
    func setAuthToken(token: String) {
        guard let tokenData = token.data(using: .utf8) else {
            return
        }
        KeyChainService.shared.set(value: tokenData, account: account)
    }
    
    func deleteAuthToken() {
        KeyChainService.shared.delete(account: account)
    }
}
