//
//  NotesTableViewController.swift
//  NotesApp
//
//  Created by Сашок on 27.03.2022.
//

import UIKit
import CoreData

class NoteTableViewController: UITableViewController {
    // MARK: - Data provider
    private lazy var dataProvider: NotesProvider = {
        let persistentContainer = CoreDataStackHolder.shared.persistentContainer
        let provider =
            NotesProvider(persistentContainer: persistentContainer, fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = self.editButtonItem
        tableView.register(NoteTableViewCell.nib(), forCellReuseIdentifier: NoteTableViewCell.reuseId)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, _ in
            let note = self.dataProvider.fetchedResultsController.object(at: indexPath)
            self.dataProvider.delete(note: note)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Navigation
extension NoteTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showNote" else { return }
        guard let noteViewController = segue.destination as? NoteViewController else { return }
        guard let indexPath = tableView.indexPathsForSelectedRows?.first else { return }
        noteViewController.note = dataProvider.fetchedResultsController.object(at: indexPath)
        noteViewController.delegate = self
    }
}

// MARK: - NoteViewControllerDelegate
extension NoteTableViewController: NoteViewControllerDelegate {
    func updateNote(_ note: Note) {
        let noteIsEmpty = (note.title?.isEmpty ?? true) && (note.content?.isEmpty ?? true)
        
        if noteIsEmpty {
            dataProvider.delete(note: note)
        } else {
           note.managedObjectContext?.trySave()
        }
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
