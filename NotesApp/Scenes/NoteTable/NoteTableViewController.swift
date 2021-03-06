//
//  NoteTableViewController.swift
//  NotesApp
//
//  Created by Сашок on 14.05.2022.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol NoteTableDisplayLogic: AnyObject {
    func displayNewNote(viewModel: NoteTable.AddNote.ViewModel)
    
    func onBeginDataUpdates()
    func onEndDataUpdates()
    func displayDataUpdate(viewModel: NoteTable.UpdateData.ViewModel)
    
    func onFinishFilteringNotes()
    func onFinishDataSynchronization()
}

class NoteTableViewController: UITableViewController {
    // MARK: - CleanSwift scene components
    var interactor: NoteTableBusinessLogic?
    var dataSource: NoteTableDataSourceProtocol?
    var router: (NSObjectProtocol & NoteTableRoutingLogic & NoteTableDataPassing)?
    
    // MARK: - Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        makeAssembly()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeAssembly()
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        interactor?.fetchNotes()
    }
}

// MARK: - IBActions handling
extension NoteTableViewController {
    @IBAction func addButtonPressed(_ sender: Any) {
        interactor?.addNote()
    }
}

// MARK: - Routing
extension NoteTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
}

// MARK: - NoteTableDisplayLogic protocol conformance
extension NoteTableViewController: NoteTableDisplayLogic {
    func displayNewNote(viewModel: NoteTable.AddNote.ViewModel) {
        tableView.selectRow(at: viewModel.newNoteIndexPath, animated: true, scrollPosition: .top)
        performSegue(withIdentifier: "NoteDetails", sender: self)
    }
    
    func onBeginDataUpdates() {
        tableView.beginUpdates()
    }
    
    func onEndDataUpdates() {
        tableView.endUpdates()
    }
    
    func displayDataUpdate(viewModel: NoteTable.UpdateData.ViewModel) {
        guard let updateKind = viewModel.updatekind else {
            return
        }
        
        switch updateKind {
        case .insert:
            if let newIndexPath = viewModel.newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = viewModel.indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .move:
            // not using moveRow(at:to:) as it doesn't actually realod row content
            if let indexPath = viewModel.indexPath, let newIndexPath = viewModel.newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = viewModel.indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func onFinishFilteringNotes() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func onFinishDataSynchronization() {
        DispatchQueue.main.async {
            self.endRefreshing()
            self.tableView.isUserInteractionEnabled = true
        }
    }
}

// MARK: - UITableViewDataSource protocol conformance
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

// MARK: - UITableViewDelegate protocol conformance
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

// MARK: - UISearchResultsUpdating protocol conformance
extension NoteTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        let request = NoteTable.FiletrNotes.Request(searchText: searchText)
        interactor?.filterNotes(request: request)
    }
}

// MARK: - CleanSwift assembly
extension NoteTableViewController {
    private func makeAssembly() {
        let viewController = self
        let interactor = NoteTableInteractor()
        let presenter = NoteTablePresenter()
        let router = NoteTableRouter()
        let dataSource = NoteTableDataSource()
        
        dataSource.dataStore = interactor
        dataSource.presenter = presenter
        
        viewController.interactor = interactor
        viewController.router = router
        viewController.dataSource = dataSource
        
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        
        router.viewController = viewController
        router.dataStore = interactor
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(accessTokenReceived),
                                               name: .accessTokenReceived, object: nil)
    }
}

//  MARK: - Data synchronization
extension NoteTableViewController {
    @objc private func accessTokenReceived() {
        beginRefreshing()
        synchronizeData()
    }
    
    @objc private func synchronizeData() {
        tableView.isUserInteractionEnabled = false
        interactor?.synchronizeData()
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
