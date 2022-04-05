//
//  YandexDiskSyncManager.swift
//  NotesApp
//
//  Created by Сашок on 05.04.2022.
//

import Foundation

class YandexDiskSyncManager {
    static let shared = YandexDiskSyncManager()
    
    private let backedSerialQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    var accessToken: String? {
        YandexDiskTokenProvider.shared.getAuthToken()
    }
    
    private init() {}
    
    func saveNote(_ noteMO: NoteMO) {
        guard let note = noteMO.toModel() else {
            return
        }
        backedSerialQueue.addOperation(SaveNoteOperation(note: note))
    }
    
    func deleteNote(_ noteMO: NoteMO) {
        guard let id = noteMO.id else {
            return
        }
        backedSerialQueue.addOperation(DeleteNoteOperation(id: id))
    }
}
