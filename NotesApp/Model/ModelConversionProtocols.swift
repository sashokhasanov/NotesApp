//
//  ModelConversion.swift
//  NotesApp
//
//  Created by Сашок on 05.04.2022.
//

import CoreData

protocol MangedObjectConvertible {
    associatedtype ManagedObjectModel
    func toManagedObject(context: NSManagedObjectContext) -> ManagedObjectModel
}

protocol ModelConvertible {
    associatedtype Model
    func toModel() -> Model?
}
