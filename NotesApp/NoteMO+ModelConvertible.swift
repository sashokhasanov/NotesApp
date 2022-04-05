//
//  NoteMO+ModelConvertible.swift
//  NotesApp
//
//  Created by Сашок on 05.04.2022.
//
import Foundation

extension NoteMO: ModelConvertible {
    func toModel() -> Note? {
        guard let id = id else { return nil }
        return Note(id: id, title: title ?? "", content: content ?? "", color: color, pinned: pinned, date: date ?? Date())
    }
}
