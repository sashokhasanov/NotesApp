//
//  NoteTableDataSource.swift
//  NotesApp
//
//  Created by Сашок on 15.05.2022.
//

import Foundation

protocol NoteTableDataSourceProtocol {
    func getNumberOfSections() -> Int
    func getNumberOfRowsInSection(_ section: Int) -> Int
    func getCellViewModel(at indexPath: IndexPath) -> NoteTable.CellViewModel
}

class NoteTableDataSource: NoteTableDataSourceProtocol {
    var dataStore: NoteTableDataStore?
    var presenter: NoteTablePresentationLogic?
    
    func getNumberOfSections() -> Int {
        dataStore?.getNumberOfSections() ?? 0
    }
    
    func getNumberOfRowsInSection(_ section: Int) -> Int {
        dataStore?.getNumberOfRowsInSection(section) ?? 0
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> NoteTable.CellViewModel {
        guard let note = dataStore?.getNote(at: indexPath) else {
            return NoteTable.CellViewModel.emptyViewModel
        }
        return presenter?.getTableCellViewModel(note: note) ?? NoteTable.CellViewModel.emptyViewModel
    }
}
