//
//  UIButton+TapAnimation.swift
//  NotesApp
//
//  Created by Сашок on 08.04.2022.
//

import UIKit

extension UIButton {
    func tapAnimation(completion: @escaping () -> Void) {
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
