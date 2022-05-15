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
    @IBOutlet weak var pinImageView: UIImageView!
    
    static let reuseId = "NoteTableViewCell"
    static let height: CGFloat = 70
    
    static func nib() -> UINib {
        UINib(nibName: reuseId, bundle: nil)
    }
    
    func configure(with note: NoteMO) {
        titleLabel.text = note.title
        contentLabel.text = note.content
        markerView.backgroundColor = UIColor(hexValue: note.color)
        pinImageView.isHidden = !note.pinned
        pinImageView.transform = CGAffineTransform(rotationAngle: .pi / 4)
    }
    
    func configure(with viewModel: NoteTable.CellViewModel) {
        titleLabel.text = viewModel.title
        contentLabel.text = viewModel.content
        markerView.backgroundColor = UIColor(hexValue: viewModel.color)
        pinImageView.isHidden = !viewModel.pinned
        pinImageView.transform = CGAffineTransform(rotationAngle: .pi / 4)
    }
}
