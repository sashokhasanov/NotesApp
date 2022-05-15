//
//  NoteTableViewController.swift
//  NotesApp
//
//  Created by Сашок on 27.03.2022.
//

import UIKit
import CoreData

class NoteTableViewController_old: UITableViewController {
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
        setupViewController()
    }
}

// MARK: - IBActions handling
extension NoteTableViewController_old {
    @IBAction func addButtonPressed(_ sender: Any) {
        dataProvider.addNote(in: dataProvider.persistentContainer.viewContext) { newNote in
            YandexDiskSynchronizatinManager.shared.uploadNote(newNote)
            
            let indexPath =
                self.dataProvider.fetchedResultsController.indexPath(forObject: newNote)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            self.performSegue(withIdentifier: "showNote", sender: self)
        }
    }
}

// MARK: - Controller setup
extension NoteTableViewController_old {
    private func setupViewController() {
        registerCells()
        setupRefreshControl()
        setupSearchController()
        setupNotificationsObservation()
    }
    
    private func registerCells() {
        tableView.register(NoteTableViewCell.nib(), forCellReuseIdentifier: NoteTableViewCell.reuseId)
    }
    
    private func setupSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"

        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(synchronizeData), for: .valueChanged)
    }
    
    private func setupNotificationsObservation() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextDidSave),
                                               name: .NSManagedObjectContextDidSave, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(accessTokenReceived),
                                               name: .accessTokenReceived, object: nil)
    }
}

// MARK: - Refreshing state management
extension NoteTableViewController_old {
    private func beginRefreshing() {
        guard let refreshControl = refreshControl else { return }
        guard !refreshControl.isRefreshing else { return }
        let verticalOffset = tableView.contentOffset.y - refreshControl.frame.size.height

        refreshControl.beginRefreshing()
        tableView.setContentOffset(CGPoint(x: 0, y: verticalOffset), animated: true)
    }

    private func endRefreshing() {
        refreshControl?.endRefreshing()
    }
}

// MARK: - Table view data source
extension NoteTableViewController_old {
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
extension NoteTableViewController_old {
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
            YandexDiskSynchronizatinManager.shared.uploadNote(note)
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
            YandexDiskSynchronizatinManager.shared.uploadNote(note)
            self.dataProvider.save(note: note)
            completion(true)
        }
        pinAction.backgroundColor = UIColor.systemYellow
        pinAction.image = UIImage(systemName: note.pinned ? "pin.slash.fill" : "pin.fill")
        
        return UISwipeActionsConfiguration(actions: [pinAction])
    }
}

// MARK: - Navigation
extension NoteTableViewController_old {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showNote" else { return }
        guard let noteViewController = segue.destination as? NoteDetailsViewController else { return }
        guard let indexPath = tableView.indexPathsForSelectedRows?.first else { return }
        noteViewController.hidesBottomBarWhenPushed = true
        
//        if let ds = noteViewController.interactor as? NoteDetailsDataStore {
//            ds.note = dataProvider.fetchedResultsController.object(at: indexPath)
//        }
//        noteViewController.delegate = self
    }
}

// MARK: - NoteViewControllerDelegate
extension NoteTableViewController_old: NoteViewControllerDelegate {
    func updateNote(_ note: NoteMO) {
        let noteIsEmpty = (note.title?.isEmpty ?? true) && (note.content?.isEmpty ?? true)
        
        if noteIsEmpty {
            YandexDiskSynchronizatinManager.shared.deleteNote(note)
            dataProvider.delete(note: note)
        } else {
            YandexDiskSynchronizatinManager.shared.uploadNote(note)
            dataProvider.save(note: note)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension NoteTableViewController_old: NSFetchedResultsControllerDelegate {
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
extension NoteTableViewController_old: UISearchResultsUpdating {
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

//  MARK: - Data synchronization
extension NoteTableViewController_old {
    @objc private func managedObjectContextDidSave(notification: Notification) {
        let viewContext = dataProvider.persistentContainer.viewContext
        
        viewContext.perform {
            viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc private func accessTokenReceived() {
        beginRefreshing()
        synchronizeData()
    }
    
    @objc private func synchronizeData() {
        tableView.isUserInteractionEnabled = false
        YandexDiskSynchronizatinManager.shared.syncData {
            DispatchQueue.main.async {
                self.endRefreshing()
                self.tableView.isUserInteractionEnabled = true
            }
        }
    }
}
