//
//  NotesTableViewController.swift
//  NotesApp
//
//  Created by Сашок on 27.03.2022.
//

import UIKit
import CoreData

class NoteTableViewController: UITableViewController {
    // MARK: - Model data
//    var notes = NoteTemp.getMockData()
    
    private lazy var dataProvider: NotesProvider = {
        let persistentContainer = CoreDataStackHolder.shared.persistentContainer
        let provider =
            NotesProvider(persistentContainer: persistentContainer, fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(NoteTableViewCell.nib(), forCellReuseIdentifier: NoteTableViewCell.reuseId)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
//        performSegue(withIdentifier: "showNote", sender: self)
        dataProvider.addNote(in: dataProvider.persistentContainer.viewContext) { newNote in
            let indexPath =
                self.dataProvider.fetchedResultsController.indexPath(forObject: newNote)
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
            self.performSegue(withIdentifier: "showNote", sender: self)
        }
        
    }
}

// MARK: - Table view data source
extension NoteTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = dataProvider.fetchedResultsController.sections else {
            return 1
        }
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = dataProvider.fetchedResultsController.sections else {
            return 0
        }
    
        return sections[section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseId, for: indexPath)

        if let noteCell = cell as? NoteTableViewCell {
            let note = dataProvider.fetchedResultsController.object(at: indexPath)
            noteCell.configure(with: note)
        }

        return cell
    }
}

// MARK: - Table view delegate
extension NoteTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showNote", sender: self)
    }
}

// MARK: - Navigation
extension NoteTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showNote" else { return }
        guard let noteViewController = segue.destination as? NoteViewController else { return }
        guard let indexPath = tableView.indexPathsForSelectedRows?.first else { return }
        noteViewController.delegate = self
        noteViewController.note = dataProvider.fetchedResultsController.object(at: indexPath)
    }
}

// MARK: - NoteViewControllerDelegate
extension NoteTableViewController: NoteViewControllerDelegate {
    func updateNote(with newNote: NoteTemp) {
//        if let index = notes.firstIndex(where: { note in newNote.id == note.id }) {
//            notes[index] = newNote
//            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//        } else {
//            notes.append(newNote)
//            tableView.insertRows(at: [IndexPath(row: notes.count - 1, section: 0)], with: .automatic)
//        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension NoteTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
