//
//  ViewController.swift
//  NotesApp
//
//  Created by Сашок on 24.03.2022.
//

import UIKit

class NoteViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var noteMarkerView: UIView!
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteContentTextView: UITextView!
    
    @IBOutlet var colorViews: [CircleMarkerView]!
    @IBOutlet weak var customColorView: GradientMarkerView!
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }
    
    // MARK: - IBActions
    @IBAction func predefinedColorTapped(_ sender: UITapGestureRecognizer) {
        guard let currentView = sender.view else {
            return
        }
        
        for view in colorViews {
            view.showMarker = view === currentView as? CircleMarkerView
        }
        
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

// MARK: - Private methods
extension NoteViewController {
    private func setupViewController() {
        noteTitleTextField.delegate = self
        setupNoteContentAccessoryView()
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
        updateNoteMarker(with: viewController.selectedColor)
        customColorView.backgroundColor = viewController.selectedColor
    }
}
