//
//  NoteDetailsPresenter.swift
//  NotesApp
//
//  Created by Сашок on 13.05.2022.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

protocol NoteDetailsPresentationLogic {
    func presentNote(response: NoteDetails.ShowNote.Response)
    func presentNoteColor(response: NoteDetails.SetNoteColor.Response)
}

class NoteDetailsPresenter: NoteDetailsPresentationLogic {
    weak var viewController: NoteDetailsDisplayLogic?
    private let defaultNoteColor: Int64 = 0xFFFF0033
    
    func presentNote(response: NoteDetails.ShowNote.Response) {
        let title = response.note?.title ?? ""
        let content = response.note?.content ?? ""
        let navigationTitle = (title.isEmpty && content.isEmpty) ? "Новая заметка" : "Редактирование"
        let color = response.note?.color ?? defaultNoteColor
        
        let viewModel = NoteDetails.ShowNote.ViewModel(title: title,
                                                       content: content,
                                                       color: color,
                                                       navigationTitle: navigationTitle)
        
        viewController?.displayNoteDetails(viewModel: viewModel)
    }
    
    func presentNoteColor(response: NoteDetails.SetNoteColor.Response) {
        let viewModel = NoteDetails.SetNoteColor.ViewModel(color: response.color)
        viewController?.displayNoteColor(viewModel: viewModel)
    }
}
