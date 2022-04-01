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
    
    @IBOutlet weak var syncButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    @IBAction func syncButtonPressed(_ sender: Any) {
        
        AuthentificationService.shared.processAuthentification { result in
            switch result {
            case .success(let url):
                self.processUrl(url: url)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func processUrl(url: URL) {
        guard let fragment = url.fragment,
              let dummyURL = URL(string: "http://dummyurl.com?\(fragment)"),
              let components = URLComponents(url: dummyURL, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return }

        // save token to keychain
        
        updateUI()
    }
    
    func updateUI() {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
