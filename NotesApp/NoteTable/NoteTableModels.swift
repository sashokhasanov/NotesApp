//
//  NoteTableModels.swift
//  NotesApp
//
//  Created by Сашок on 14.05.2022.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import Foundation

enum NoteTable {
    enum AddNote {
        struct Response {
            let newNoteIndexPath: IndexPath?
        }
        
        struct ViewModel {
            let newNoteIndexPath: IndexPath?
        }
    }
    
    enum DeleteNote {
        struct Request {
            let indexPath: IndexPath
        }
    }
    
    enum PinNote {
        struct Request {
            let indexPath: IndexPath
        }
    }
    
    enum FiletrNotes {
        struct Request {
            let searchText: String
        }
    }
    
    enum UpdateData {
        struct Response {
            let updatekind: UpdateKind?
            let indexPath: IndexPath?
            let newIndexPath: IndexPath?
        }
        
        struct ViewModel {
            let updatekind: UpdateKind?
            let indexPath: IndexPath?
            let newIndexPath: IndexPath?
        }
        
        enum UpdateKind {
            case insert
            case update
            case move
            case delete
        }
    }
    
    struct CellViewModel {
        let title: String
        let content: String
        let color: Int64
        let pinned: Bool
        
        static let emptyViewModel = CellViewModel(title: "", content: "", color: 0, pinned: false)
    }
}
