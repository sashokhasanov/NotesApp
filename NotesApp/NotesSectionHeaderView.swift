//
//  NotesSectionHeaderView.swift
//  NotesApp
//
//  Created by Сашок on 29.03.2022.
//

import UIKit

class NotesSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    
    static let reuseId = "NotesSectionHeaderView"
    static let headerHeight: CGFloat = 80
    
    static func nib() -> UINib {
        UINib(nibName: reuseId, bundle: nil)
    }
}
