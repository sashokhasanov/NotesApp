//
//  SyncModels.swift
//  NotesApp
//
//  Created by Сашок on 13.05.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

enum Sync {
 
    enum UpdateAuthenticationStatus {
        struct Response {
            let isAuthenticated: Bool
        }
        
        struct ViewModel {
            let isAuthenticated: Bool
            let imageName: String
            let syncStatus: String
        }
    }
}
