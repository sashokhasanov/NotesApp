//
//  KeyChainHelper.swift
//  NotesApp
//
//  Created by Сашок on 01.04.2022.
//

import Foundation

class KeyChainService {
    static let shared = KeyChainService()
    private let serviceId = "ru.awesome.NotesApp.KeychainService"
    
    private init() {}
    
    func set(value: Data, account: String) throws {

        if try exists(account: account) {
            try update(value: value, account: account)
        } else {
            try add(value: value, account: account)
        }
    }
    
    func get(account: String) throws -> Data? {
        var result: AnyObject?

        let status = SecItemCopyMatching([kSecClass: kSecClassGenericPassword,
                                          kSecAttrService: serviceId,
                                          kSecAttrAccount: account,
                                          kSecReturnData: true] as NSDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeyChainError.readError
        }
    }
    
    func delete(account: String) throws {
        let status = SecItemDelete([kSecClass: kSecClassGenericPassword,
                                    kSecAttrService: serviceId,
                                    kSecAttrAccount: account] as NSDictionary)
        
        guard status == errSecSuccess else {
            throw KeyChainError.deleteError
        }
    }

    
    private func exists(account: String) throws -> Bool {
        let status = SecItemCopyMatching([kSecClass: kSecClassGenericPassword,
                                          kSecAttrService: serviceId,
                                          kSecAttrAccount: account,
                                          kSecReturnData: false] as NSDictionary, nil)
        
        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw KeyChainError.lookUpError
        }
    }
    
    private func add(value: Data, account: String) throws {
        let status = SecItemAdd([kSecClass: kSecClassGenericPassword,
                                 kSecAttrService: serviceId,
                                 kSecAttrAccount: account,
                                 kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
                                 kSecValueData: value] as NSDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeyChainError.createError
        }
    }
    
    private func update(value: Data, account: String) throws {
        let status = SecItemUpdate([kSecClass: kSecClassGenericPassword,
                                    kSecAttrService: serviceId,
                                    kSecAttrAccount: account] as NSDictionary, [kSecValueData: value] as NSDictionary)
        
        guard status == errSecSuccess else {
            throw KeyChainError.updateError
        }
    }
}

extension KeyChainService {
    enum KeyChainError: Error {
        case createError
        case lookUpError
        case readError
        case updateError
        case deleteError
        case unknownError
    }
}
