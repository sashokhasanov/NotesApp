//
//  ViewController.swift
//  NotesApp
//
//  Created by Сашок on 24.03.2022.
//

import UIKit

protocol NoteViewControllerDelegate {
    func updateNote(with newNote: NoteTemp)
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
    var delegate: NoteViewControllerDelegate?
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setDataToControls()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        let id = note?.id ?? UUID()
//        let title = noteTitleTextField.text ?? ""
//        let content = noteContentTextView.text ?? ""
//        let color = (noteMarkerView.backgroundColor ?? UIColor.systemPink).hexValue
//        let date = Date()
//
//        let newNote = NoteTemp(id: id, title: title, content: content, color: color, date: date)
//
//        delegate?.updateNote(with: newNote)
//    }
    
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
        setupNoteColor()
    }
    
    private func setupNoteColor() {
        guard let note = note else { return }
        
        for colorView in colorViews {
            if colorView is GradientMarkerView {
                customColorView.backgroundColor = (note.color as? UIColor) ?? UIColor.systemPink
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
        
        return (note.color as? UIColor)?.hexValue ?? 0 == color.hexValue
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
