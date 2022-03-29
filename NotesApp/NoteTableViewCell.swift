//
//  NoteTableViewCell.swift
//  NotesApp
//
//  Created by Сашок on 27.03.2022.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var markerView: CircleMarkerView!
    
    static let reuseId = "NoteTableViewCell"
    static let height: CGFloat = 90
    
    static func nib() -> UINib {
        UINib(nibName: reuseId, bundle: nil)
    }
    
    func configure(with note: Note) {
        titleLabel.text = note.title
        contentLabel.text = note.content
        markerView.backgroundColor = UIColor(hexValue: note.color)
    }
}
