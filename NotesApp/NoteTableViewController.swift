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
    
    private let searchController = UISearchController()
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        tableView.register(NoteTableViewCell.nib(), forCellReuseIdentifier: NoteTableViewCell.reuseId)
    }
    
    // MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: Any) {
        dataProvider.addNote(in: dataProvider.persistentContainer.viewContext) { newNote in
            let indexPath =
                self.dataProvider.fetchedResultsController.indexPath(forObject: newNote)
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
            self.performSegue(withIdentifier: "showNote", sender: self)
        }
    }
    
    // MARK: - Private methods
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"

        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

// MARK: - Table view data source
extension NoteTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = dataProvider.fetchedResultsController.sections else {
            return 0
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
        NoteTableViewCell.height
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showNote", sender: self)
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let note = self.dataProvider.fetchedResultsController.object(at: indexPath)
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, _ in
            self.dataProvider.delete(note: note)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let note = self.dataProvider.fetchedResultsController.object(at: indexPath)
        
        let pinAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            note.pinned.toggle()
            self.dataProvider.save(note: note)
            completion(true)
        }
        pinAction.backgroundColor = UIColor.systemYellow
        pinAction.image = UIImage(systemName: note.pinned ? "pin.slash.fill" : "pin.fill")
        
        return UISwipeActionsConfiguration(actions: [pinAction])
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
            dataProvider.save(note: note)
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
            // not using moveRow(at:to:) as it doesn't actually realod row content
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: - UISearchResultsUpdating
extension NoteTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        
        var searchPredicate: NSPredicate?
        if !searchText.isEmpty {
            searchPredicate =
                NSPredicate(format: "(title contains[cd] %@) || (content contains[cd] %@)", searchText, searchText)
        }

        dataProvider.fetchedResultsController.fetchRequest.predicate = searchPredicate
        do {
            try dataProvider.fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
}
