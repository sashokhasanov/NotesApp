//
//  NoteTableViewController.swift
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
import CoreData
import Alamofire


protocol NoteTableDataSourceProtocol {
    func getNumberOfSections() -> Int
    func getNumberOfRowsInSection(_ section: Int) -> Int
    func getCellViewModel(at indexPath: IndexPath) -> NoteTable.CellViewModel
}

class NoteTableDataSource: NoteTableDataSourceProtocol {
    
    var dataStore: NoteTableDataStore?
//    var presenter: NoteTablePresentationLogic?
    
    func getNumberOfSections() -> Int {
        dataStore?.getNumberOfSections() ?? 0
    }
    
    func getNumberOfRowsInSection(_ section: Int) -> Int {
        dataStore?.getNumberOfRowsInSection(section) ?? 0
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> NoteTable.CellViewModel {
        let note = dataStore?.getNote(at: indexPath)
        
        let title = note?.title ?? ""
        let content = note?.content ?? ""
        let color = note?.color ?? 0xFFFF0033
        let pinned = note?.pinned ?? false
        
        let viewModel = NoteTable.CellViewModel(
            title: title,
            content: content,
            color: color,
            pinned: pinned
        )
        return viewModel
    }
    
    
}


protocol NoteTableDisplayLogic: AnyObject {
    func displayNewNote(viewModel: NoteTable.AddNote.ViewModel)
    
    
    func beginTableUpdates()
    func endTableUpdates()
    
    func insertRow(at indexPath: IndexPath)
    func updateRow(at indexPath: IndexPath)
    func deleteRow(at indexPath: IndexPath)
    func moveRow(from oldIndexPath: IndexPath, to newIndexPath: IndexPath)
    
    func reloadTable()
    
    func endRefreshing1()
}

class NoteTableViewController: UITableViewController {
        
    // MARK: - Data provider
//    private lazy var dataProvider: NotesProvider = {
//        let persistentContainer = CoreDataStackHolder.shared.persistentContainer
//        let provider =
//            NotesProvider(persistentContainer: persistentContainer, fetchedResultsControllerDelegate: self)
//        return provider
//    }()
    
    var interactor: NoteTableBusinessLogic?
    var dataSource: NoteTableDataSourceProtocol?
    var router: (NSObjectProtocol & NoteTableRoutingLogic & NoteTableDataPassing)?
    
    // MARK: Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        interactor?.fetchNotes()
    }
    
    // MARK: Routing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }

    
    // MARK: Setup
    private func setup() {
        let viewController = self
        let interactor = NoteTableInteractor()
        let presenter = NoteTablePresenter()
        let router = NoteTableRouter()
        let dataSource = NoteTableDataSource()
        
        dataSource.dataStore = interactor
        
        viewController.interactor = interactor
        viewController.router = router
        
        
        
        viewController.dataSource = dataSource
        
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    
    private func getNotes() {
        interactor?.fetchNotes()
    }
}

extension NoteTableViewController: NoteTableDisplayLogic {
    
    func displayNewNote(viewModel: NoteTable.AddNote.ViewModel) {
        self.tableView.selectRow(at: viewModel.newNoteIndexPath, animated: true, scrollPosition: .top)
        self.performSegue(withIdentifier: "NoteDetails", sender: self)
    }
    
    func beginTableUpdates() {
        tableView.beginUpdates()
    }
    
    func endTableUpdates() {
        tableView.endUpdates()
    }
    
    func insertRow(at indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func updateRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func deleteRow(at indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func moveRow(from oldIndexPath: IndexPath, to newIndexPath: IndexPath) {
        tableView.deleteRows(at: [oldIndexPath], with: .automatic)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    func endRefreshing1() {
        
        DispatchQueue.main.async {
            self.endRefreshing()
            self.tableView.isUserInteractionEnabled = true
        }
    }
}

// MARK: - IBActions handling
extension NoteTableViewController {
    @IBAction func addButtonPressed(_ sender: Any) {
        
        interactor?.addNote()
        
        
//        dataProvider.addNote(in: dataProvider.persistentContainer.viewContext) { newNote in
//            YandexDiskSynchronizatinManager.shared.uploadNote(newNote)
//
//            let indexPath =
//                self.dataProvider.fetchedResultsController.indexPath(forObject: newNote)
//            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//            self.performSegue(withIdentifier: "showNote", sender: self)
//        }
    }
}

// MARK: - Controller setup
extension NoteTableViewController {
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
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(managedObjectContextDidSave),
//                                               name: .NSManagedObjectContextDidSave, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(accessTokenReceived),
                                               name: .accessTokenReceived, object: nil)
    }
}

// MARK: - Refresh control management
extension NoteTableViewController {
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
extension NoteTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource?.getNumberOfSections() ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource?.getNumberOfRowsInSection(section) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseId, for: indexPath)

        if let noteCell = cell as? NoteTableViewCell {
            if let viewModel = dataSource?.getCellViewModel(at: indexPath) {
                noteCell.configure(with: viewModel)
            }
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
        performSegue(withIdentifier: "NoteDetails", sender: self)
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, _ in
            let request = NoteTable.DeleteNote.Request(indexPath: indexPath)
            self.interactor?.deleteNote(request: request)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let pinAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            let request = NoteTable.PinNote.Request(indexPath: indexPath)
            self.interactor?.pinNote(request: request)
        }
        pinAction.backgroundColor = UIColor.systemYellow
        
        var pinned = false
        if let viewModel = dataSource?.getCellViewModel(at: indexPath) {
            pinned = viewModel.pinned
        }
        pinAction.image = UIImage(systemName: pinned ? "pin.slash.fill" : "pin.fill")
        
        return UISwipeActionsConfiguration(actions: [pinAction])
    }
}

// MARK: - Navigation
//extension NoteTableViewController {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard segue.identifier == "showNote" else { return }
//        guard let noteViewController = segue.destination as? NoteDetailsViewController else { return }
//        guard let indexPath = tableView.indexPathsForSelectedRows?.first else { return }
//        noteViewController.hidesBottomBarWhenPushed = true
//        
//        if let ds = noteViewController.interactor as? NoteDetailsDataStore {
//            ds.note = dataProvider.fetchedResultsController.object(at: indexPath)
//        }
////        noteViewController.delegate = self
//    }
//}

// MARK: - NoteViewControllerDelegate
//extension NoteTableViewController: NoteViewControllerDelegate {
//    func updateNote(_ note: NoteMO) {
//        let noteIsEmpty = (note.title?.isEmpty ?? true) && (note.content?.isEmpty ?? true)
//
//        if noteIsEmpty {
//            YandexDiskSynchronizatinManager.shared.deleteNote(note)
//            dataProvider.delete(note: note)
//        } else {
//            YandexDiskSynchronizatinManager.shared.uploadNote(note)
//            dataProvider.save(note: note)
//        }
//    }
//}

// MARK: - NSFetchedResultsControllerDelegate
//extension NoteTableViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
//                    didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            tableView.insertRows(at: [newIndexPath!], with: .automatic)
//        case .update:
//            tableView.reloadRows(at: [indexPath!], with: .automatic)
//        case .move:
//            // not using moveRow(at:to:) as it doesn't actually realod row content
//            tableView.deleteRows(at: [indexPath!], with: .automatic)
//            tableView.insertRows(at: [newIndexPath!], with: .automatic)
//        case .delete:
//            tableView.deleteRows(at: [indexPath!], with: .automatic)
//        @unknown default:
//            break
//        }
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
//}

// MARK: - UISearchResultsUpdating
extension NoteTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        let request = NoteTable.FiletrNotes.Request(searchText: searchText)
        interactor?.filterNotes(request: request)
    }
}

//  MARK: - Data synchronization
extension NoteTableViewController {
//    @objc private func managedObjectContextDidSave(notification: Notification) {
//        let viewContext = dataProvider.persistentContainer.viewContext
//        
//        viewContext.perform {
//            viewContext.mergeChanges(fromContextDidSave: notification)
//        }
//    }
    
    @objc private func accessTokenReceived() {
        beginRefreshing()
        synchronizeData()
    }
    
    @objc private func synchronizeData() {
        tableView.isUserInteractionEnabled = false
        interactor?.synchronizeData()
        
        
//        YandexDiskSynchronizatinManager.shared.syncData {
//            DispatchQueue.main.async {
//                self.endRefreshing()
//                self.tableView.isUserInteractionEnabled = true
//            }
//        }
    }
}
