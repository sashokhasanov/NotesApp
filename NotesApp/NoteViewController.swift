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
    
    // MARK: - Internal properties
    var note: Note?
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
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
                customColorView.backgroundColor = getColor(from: note.color)
            }

            if checkNeedSelectColorView(view: colorView) {
                selectColorView(colorView: colorView)
                if let color = colorView.backgroundColor {
                    updateNoteMarker(with: color)
                }
            }
        }
    }
    
    private func checkNeedSelectColorView(view: CircleMarkerView) -> Bool {
        guard !(view is GradientMarkerView) else { return true }
        guard let color = view.backgroundColor, let note = note else { return false }
        
        return note.color == getColorValue(from: color)
    }
    
    private func getColor(from value: Int32) -> UIColor {
        let alpha = CGFloat((value >> 24) & 0xFF) / 255.0
        let red = CGFloat((value >> 16) & 0xFF) / 255.0
        let green = CGFloat((value >> 8) & 0xFF) / 255.0
        let blue = CGFloat(value & 0xFF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    private func getColorValue(from color: UIColor) -> Int32 {
        let currentColor = color.ciColor
        
        let red = Int32(currentColor.red * 255.0)
        let green = Int32(currentColor.green * 255.0)
        let blue = Int32(currentColor.blue * 255.0)
        let alpha = Int32(currentColor.alpha * 255.0)
        
        return Int32((alpha << 24) + (red << 16) + (green << 8) + blue)
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
        customColorView.backgroundColor = viewController.selectedColor
        updateNoteMarker(with: viewController.selectedColor)
    }
}
