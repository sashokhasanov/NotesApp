//
//  LoginViewController.swift
//  NotesApp
//
//  Created by Сашок on 01.04.2022.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginStatusImageView: UIImageView!
    @IBOutlet weak var loginStatusLabel: UILabel!
    
    @IBOutlet weak var loginElementsStackView: UIStackView!
    @IBOutlet weak var logoffElementsStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    @IBAction func syncButtonPressed(_ sender: UIButton) {
        sender.pressAnimation {
            AuthentificationService.shared.processAuthentification { result in
                switch result {
                case .success(let url):
                    self.processUrl(url: url)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @IBAction func logoffButtonPressed(_ sender: UIButton) {
        
        sender.pressAnimation {
            KeyChainService.shared.delete(account: "YandexDisk")
            self.updateUI()
        }
        
    }
    
    func processUrl(url: URL) {
        guard let fragment = url.fragment,
              let dummyURL = URL(string: "http://dummyurl.com?\(fragment)"),
              let components = URLComponents(url: dummyURL, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return }

        if let token = queryItems.first(where: { $0.name == "access_token" })?.value, let tokenData = token.data(using: .utf8) {
            KeyChainService.shared.set(value: tokenData, account: "YandexDisk")
        }

        updateUI()
    }

    func updateUI() {
        if KeyChainService.shared.get(account: "YandexDisk") != nil {
            loginStatusImageView.image = UIImage(systemName: "checkmark.icloud")
            loginStatusLabel.text = "Синхронизация включена"
            loginElementsStackView.isHidden = true
            logoffElementsStackView.isHidden = false
        } else {
            loginStatusImageView.image = UIImage(systemName: "xmark.icloud")
            loginStatusLabel.text = "Синхронизация выключена"
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
