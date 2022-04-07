//
//  LoginViewController.swift
//  NotesApp
//
//  Created by Сашок on 01.04.2022.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var syncStatusImageView: UIImageView!
    @IBOutlet weak var syncStatusLabel: UILabel!
    
    @IBOutlet weak var loginElementsStackView: UIStackView!
    @IBOutlet weak var logoffElementsStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    @IBAction func syncButtonPressed(_ sender: UIButton) {
        sender.pressAnimation {
            YandexDiskAuthenticationService.shared.processAuthentication { result in
                switch result {
                case .success(let token):
                    YandexDiskTokenProvider.shared.setAuthToken(token: token)
                    self.updateUI()
                    NotificationCenter.default.post(name: NSNotification.Name("accessTokenGranted"), object: nil)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @IBAction func logoffButtonPressed(_ sender: UIButton) {
        sender.pressAnimation {
            YandexDiskTokenProvider.shared.deleteAuthToken()
            self.updateUI()
        }
    }
    
    private func updateUI() {
        if YandexDiskTokenProvider.shared.getAuthToken() != nil {
            syncStatusImageView.image = UIImage(systemName: "checkmark.icloud")
            syncStatusLabel.text = "Синхронизация включена"
            loginElementsStackView.isHidden = true
            logoffElementsStackView.isHidden = false
        } else {
            syncStatusImageView.image = UIImage(systemName: "xmark.icloud")
            syncStatusLabel.text = "Синхронизация выключена"
            loginElementsStackView.isHidden = false
            logoffElementsStackView.isHidden = true
        }
    }
}

extension UIButton {
    func pressAnimation(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            } completion: { _ in
                completion()
            }
        }
    }
}
