//
//  Model.swift
//  NotesApp
//
//  Created by Сашок on 05.04.2022.
//

import Foundation

struct UrlResponse: Decodable {
    let href: String
    let method: String
}

struct Resource: Decodable {
    let name: String
    let path: String
    let _embedded: ResourceList?
}

struct ResourceList: Decodable {
    let items: [Resource]
}

struct Note: Codable {
    let id: UUID
    let title: String
    let content: String
    let color: Int64
    let pinned: Bool
    let date: Date
}
