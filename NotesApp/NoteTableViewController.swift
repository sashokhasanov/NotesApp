//
//  NotesTableViewController.swift
//  NotesApp
//
//  Created by Сашок on 27.03.2022.
//

import UIKit

class NoteTableViewController: UITableViewController {
    // MARK: - Model data
    var notes = Note.getMockData()
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(NoteTableViewCell.nib(), forCellReuseIdentifier: NoteTableViewCell.reuseId)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showNote", sender: self)
    }
}

// MARK: - Table view data source
extension NoteTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseId, for: indexPath)

        if let noteCell = cell as? NoteTableViewCell {
            noteCell.configure(with: notes[indexPath.row])
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
        noteViewController.delegate = self
        if let noteIndex = tableView.indexPathsForSelectedRows?.first?.row {
            noteViewController.note = notes[noteIndex]
        }
    }
}

// MARK: - NoteViewControllerDelegate
extension NoteTableViewController: NoteViewControllerDelegate {
    func updateNote(with newNote: Note) {
        if let index = notes.firstIndex(where: { note in newNote.id == note.id }) {
            notes[index] = newNote
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        } else {
            notes.append(newNote)
            tableView.insertRows(at: [IndexPath(row: notes.count - 1, section: 0)], with: .automatic)
        }
    }
}
