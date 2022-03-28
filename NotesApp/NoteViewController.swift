//
//  NoteViewController.swift
//  NotesApp
//
//  Created by Сашок on 24.03.2022.
//

import UIKit

protocol NoteViewControllerDelegate: AnyObject {
    func updateNote(_ note: Note)
}

class NoteViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var noteMarkerView: UIView!
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteContentTextView: UITextView!
    
    @IBOutlet var colorViews: [CircleMarkerView]!
    @IBOutlet weak var customColorView: GradientMarkerView!
    
    // MARK: - Internal properties
    var note: Note!
    weak var delegate: NoteViewControllerDelegate?
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setDataToControls()
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        note.title = noteTitleTextField.text ?? ""
        note.content = noteContentTextView.text ?? ""
        note.color = (noteMarkerView.backgroundColor ?? UIColor.systemPink).hexValue
        note.date = Date()

        delegate?.updateNote(note)
    }
    
    // MARK: - IBActions
    @IBAction func predefinedColorTapped(_ sender: UITapGestureRecognizer) {
        guard let currentView = sender.view as? CircleMarkerView else {
            return
        }
        
        selectColorView(colorView: currentView)
        
        if let color = currentView.backgroundColor {
            updateNoteMarker(with: color)
        } else if currentView is GradientMarkerView {
            showColorPicker(with: nil)
        }
    }
    
    @IBAction func customColorLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else {
            return
        }
        showColorPicker(with: customColorView.backgroundColor)
    }
}

// MARK: - Text field delegate
extension NoteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === noteTitleTextField {
            noteContentTextView.becomeFirstResponder()
        }
        return true
    }
}

// MARK: Color picker view controller delegate
extension NoteViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        customColorView.backgroundColor = viewController.selectedColor
        updateNoteMarker(with: viewController.selectedColor)
    }
}

// MARK: - Private methods
extension NoteViewController {
    private func setupViewController() {
        noteTitleTextField.delegate = self
        setupNoteContentAccessoryView()
        setupNavigationBar()
    }
    
    private func setupNoteContentAccessoryView() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let hideKeyboardIcon =
            UIImage(systemName: "keyboard.chevron.compact.down")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        let hideKeyboardItem =
            UIBarButtonItem(image: hideKeyboardIcon, style: .plain, target: self, action: #selector(hideKeyboard))
        
        toolbar.items = [flexibleSpaceItem, hideKeyboardItem]
        
        noteContentTextView.inputAccessoryView = toolbar
    }
    
    @objc private func hideKeyboard() {
        noteContentTextView.endEditing(true)
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backButtonTitle = ""
        }
        
        if note == nil {
            navigationItem.title = "Новая заметка"
        } else {
            navigationItem.title = "Редактирование"
        }
    }
    
    private func setDataToControls() {
        guard let note = note else { return }
        
        noteTitleTextField.text = note.title
        noteContentTextView.text = note.content
        setupNoteMarkerColor()
    }
    
    private func setupNoteMarkerColor() {
        for colorView in colorViews {
            if colorView is GradientMarkerView {
                customColorView.backgroundColor = UIColor(hexValue: note.color)
            }

            if checkNeedSelectColorView(view: colorView) {
                selectColorView(colorView: colorView)
                if let color = colorView.backgroundColor {
                    updateNoteMarker(with: color)
                }
                break
            }
        }
    }
    
    private func checkNeedSelectColorView(view: CircleMarkerView) -> Bool {
        guard !(view is GradientMarkerView) else { return true }
        guard let color = view.backgroundColor else { return false }
        
        return note.color == color.hexValue
    }
    
    private func selectColorView(colorView: CircleMarkerView) {
        for view in colorViews {
            view.showMarker = view === colorView
        }
    }
    
    private func updateNoteMarker(with color: UIColor) {
        UIView.animate(withDuration: 0.3) {
            self.noteMarkerView.backgroundColor = color
        }
    }
    
    private func showColorPicker(with selectedColor: UIColor?) {
        let colorPickerController = UIColorPickerViewController()
        if let selectedColor = selectedColor {
            colorPickerController.selectedColor = selectedColor
        }
        colorPickerController.delegate = self
        present(colorPickerController, animated: true)
    }
}
