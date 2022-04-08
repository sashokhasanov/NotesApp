//
//  LoginViewController.swift
//  NotesApp
//
//  Created by Сашок on 01.04.2022.
//

import UIKit

class SynchronizationViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var synchronizationStatusLabel: UILabel!
    @IBOutlet weak var synchronizationStatusImageView: UIImageView!
    @IBOutlet weak var enableSynchronizationElementsStackView: UIStackView!
    @IBOutlet weak var disableSynchronizationElementsStackView: UIStackView!
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    @IBAction func enableSynchronizationButtonTapped(_ sender: UIButton) {
        sender.tapAnimation {
            YandexDiskAuthenticationService.shared.processAuthentication { result in
                switch result {
                case .success(let token):
                    YandexDiskTokenProvider.shared.setAuthToken(token: token)
                    NotificationCenter.default.post(name: .accessTokenReceived, object: nil)
                    self.updateUI()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @IBAction func disableSynchronizationButtonTapped(_ sender: UIButton) {
        sender.tapAnimation {
            YandexDiskTokenProvider.shared.deleteAuthToken()
            self.updateUI()
        }
    }
    
    private func updateUI() {
        if YandexDiskTokenProvider.shared.getAuthToken() != nil {
            synchronizationStatusImageView.image = UIImage(systemName: "checkmark.icloud")
            synchronizationStatusLabel.text = "Синхронизация включена"
            enableSynchronizationElementsStackView.isHidden = true
            disableSynchronizationElementsStackView.isHidden = false
        } else {
            synchronizationStatusImageView.image = UIImage(systemName: "xmark.icloud")
            synchronizationStatusLabel.text = "Синхронизация выключена"
            enableSynchronizationElementsStackView.isHidden = false
            disableSynchronizationElementsStackView.isHidden = true
        }
    }
}


