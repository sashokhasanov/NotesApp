//
//  NoteDetailsViewController.swift
//  NotesApp
//
//  Created by Сашок on 13.05.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol NoteDetailsDisplayLogic: AnyObject {
    func displayNoteDetails(viewModel: NoteDetails.ShowNote.ViewModel)
    func displayNoteColor(viewModel: NoteDetails.SetNoteColor.ViewModel)
}

class NoteDetailsViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var noteMarkerView: UIView!
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteContentTextView: UITextView!
    @IBOutlet weak var customColorView: GradientMarkerView!
    @IBOutlet var colorViews: [CircleMarkerView]!

    var interactor: NoteDetailsBusinessLogic?
    var router: (NSObjectProtocol & NoteDetailsRoutingLogic & NoteDetailsDataPassing)?
    
    // MARK: - Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        interactor?.provideNote()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        interactor?.saveNote()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        interactor?.saveNote()
//    }
}

// MARK: - User actions handling
extension NoteDetailsViewController {
    @IBAction func predefinedColorTapped(_ sender: UITapGestureRecognizer) {
        guard let currentView = sender.view as? CircleMarkerView else {
            return
        }
        
        if let color = currentView.backgroundColor {
            let request = NoteDetails.SetNoteColor.Request(color: color.hexValue)
            interactor?.updateNoteColor(request: request)
        } else if currentView is GradientMarkerView {
            router?.routeToColorPicker(with: nil)
        }
    }
    
    @IBAction func customColorLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else {
            return
        }
        
        router?.routeToColorPicker(with: customColorView.backgroundColor)
    }
}
    
// MARK: - Display logic
extension NoteDetailsViewController: NoteDetailsDisplayLogic {
    func displayNoteDetails(viewModel: NoteDetails.ShowNote.ViewModel) {
        navigationItem.title = viewModel.navigationTitle
        noteTitleTextField.text = viewModel.title
        noteContentTextView.text = viewModel.content

        updateNoteColor(color: viewModel.color)
    }
    
    func displayNoteColor(viewModel: NoteDetails.SetNoteColor.ViewModel) {
        updateNoteColor(color: viewModel.color)
    }
}

// MARK: - Text field delegate
extension NoteDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === noteTitleTextField {
            noteContentTextView.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField === noteTitleTextField else {
            return
        }
        
        let request = NoteDetails.SetNoteTitle.Request(title: textField.text)
        interactor?.updateNoteTitle(request: request)
    }
}

// MARK: - Text view delegate
extension NoteDetailsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView === noteContentTextView else {
            return
        }
        
        let request = NoteDetails.SetNoteContent.Request(content: textView.text)
        interactor?.updatenoteContent(request: request)
    }
}

// MARK: - Color picker view controller delegate
extension NoteDetailsViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let request = NoteDetails.SetNoteColor.Request(color: viewController.selectedColor.hexValue)
        interactor?.updateNoteColor(request: request)
    }
}

// MARK: - ViewController setup
extension NoteDetailsViewController {
    private func setupViewController() {
        noteTitleTextField.delegate = self
        noteContentTextView.delegate = self
        
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
    }
    
    private func setup() {
        let viewController = self
        let interactor = NoteDetailsInteractor()
        let presenter = NoteDetailsPresenter()
        let router = NoteDetailsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
}

// MARK: - Private methods
extension NoteDetailsViewController {
    
    private func updateNoteColor(color: Int64) {
        updateMarkerColor(with: color)
        selectColorView(with: color)
    }
    
    private func updateMarkerColor(with color: Int64) {
        UIView.animate(withDuration: 0.3) {
            self.noteMarkerView.backgroundColor = UIColor(hexValue: color)
        }
    }
    
    private func selectColorView(with color: Int64) {
        for colorView in colorViews {
            if colorView === customColorView {
                customColorView.backgroundColor = UIColor(hexValue: color)
            }

            if checkNeedSelectColorView(view: colorView, color: color) {
                selectColorView(colorView: colorView)
                break
            }
        }
    }
    
    private func checkNeedSelectColorView(view: CircleMarkerView, color: Int64) -> Bool {
        guard let viewColor = view.backgroundColor else {
            return false
        }
        
        return color == viewColor.hexValue
    }
    
    private func selectColorView(colorView: CircleMarkerView) {
        for view in colorViews {
            view.showMarker = view === colorView
        }
    }
}