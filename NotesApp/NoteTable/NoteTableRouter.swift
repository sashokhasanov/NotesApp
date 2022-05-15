//
//  NoteTableRouter.swift
//  NotesApp
//
//  Created by Сашок on 14.05.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol NoteTableRoutingLogic {
    func routeToNoteDetails(segue: UIStoryboardSegue?)
}

protocol NoteTableDataPassing {
    var dataStore: NoteTableDataStore? { get }
}

class NoteTableRouter: NSObject, NoteTableRoutingLogic, NoteTableDataPassing {
    
    weak var viewController: NoteTableViewController?
    var dataStore: NoteTableDataStore?
    
    // MARK: Routing

    func routeToNoteDetails(segue: UIStoryboardSegue?) {
        if let segue = segue {
            let destinationVC = segue.destination as! NoteDetailsViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToSomewhere(source: dataStore!, destination: &destinationDS)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "NoteDetailsViewController") as! NoteDetailsViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToSomewhere(source: dataStore!, destination: &destinationDS)
            navigateToSomewhere(source: viewController!, destination: destinationVC)
        }
    }
    
    // MARK: Navigation
    func navigateToSomewhere(source: NoteTableViewController, destination: NoteDetailsViewController) {
        source.show(destination, sender: nil)
    }

    
    // MARK: Passing data

    func passDataToSomewhere(source: NoteTableDataStore, destination: inout NoteDetailsDataStore) {
        guard let indexPath = viewController?.tableView.indexPathForSelectedRow else {
            return
        }
        destination.note = source.getNote(at: indexPath)
    }

}
