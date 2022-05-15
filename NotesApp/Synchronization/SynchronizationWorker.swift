//
//  SyncWorker.swift
//  NotesApp
//
//  Created by Сашок on 13.05.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import Foundation

class SynchronizationWorker {
    func isSynchronizationEnabled() -> Bool {
        return YandexDiskTokenProvider.shared.getAuthToken() != nil
    }
    
    func enableSynchronization(completion: @escaping () -> Void) {
        YandexDiskAuthenticationService.shared.processAuthentication { result in
            switch result {
            case .success(let token):
                YandexDiskTokenProvider.shared.setAuthToken(token: token)
                NotificationCenter.default.post(name: .accessTokenReceived, object: nil)
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }
    
    func disableSynchronization() {
        YandexDiskTokenProvider.shared.deleteAuthToken()
    }
}
