//
//  KeyChainHelper.swift
//  NotesApp
//
//  Created by Сашок on 01.04.2022.
//

import Foundation

class KeyChainService {
    static let shared = KeyChainService()
    private let serviceId = Bundle.main.bundleIdentifier ?? "ru.awesome.NotesApp.KeychainService"
    
    private init() {}
    
    @discardableResult func set(value: Data, account: String) -> Bool {

        let status = SecItemAdd([kSecClass: kSecClassGenericPassword,
                                 kSecAttrService: serviceId,
                                 kSecAttrAccount: account,
                                 kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
                                 kSecValueData: value] as NSDictionary, nil)
        
        if status == errSecDuplicateItem {
            return update(value: value, account: account)
        }
        
        return status == errSecSuccess
    }
    
    @discardableResult func get(account: String) -> Data? {
        var result: AnyObject?

        SecItemCopyMatching([kSecClass: kSecClassGenericPassword,
                             kSecAttrService: serviceId,
                             kSecAttrAccount: account,
                             kSecReturnData: true] as NSDictionary, &result)
        
        return result as? Data
    }
    
    @discardableResult func delete(account: String) -> Bool {
        let status = SecItemDelete([kSecClass: kSecClassGenericPassword,
                                    kSecAttrService: serviceId,
                                    kSecAttrAccount: account] as NSDictionary)
        
        return status == errSecSuccess
    }

    private func update(value: Data, account: String) -> Bool {
        let status = SecItemUpdate([kSecClass: kSecClassGenericPassword,
                                    kSecAttrService: serviceId,
                                    kSecAttrAccount: account] as NSDictionary, [kSecValueData: value] as NSDictionary)
        
        return status == errSecSuccess
    }
}
