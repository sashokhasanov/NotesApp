//
//  Note.swift
//  NotesApp
//
//  Created by Сашок on 27.03.2022.
//

import Foundation

struct Note {
    let id: UUID
    let title: String
    let content: String
    let color: UInt32
    let date: Date
    
    static func getMockData() -> [Note] {
        [
            Note(id: UUID(), title: "Первая заметка", content: "Тест тест тест тест тест", color: 0xffff00ff, date: Date()),
            Note(id: UUID(), title: "Вторая заметка", content: "Тест тест тест тест тест", color: 0xff00ff00, date: Date()),
            Note(id: UUID(), title: "Третья заметка", content: "Тест тест тест тест тест", color: 0xffff0000, date: Date()),
            Note(id: UUID(), title: "Четвертая заметка", content: "Тест тест тест тест тест", color: 0xff0000ff, date: Date())
        ]
    }
}
