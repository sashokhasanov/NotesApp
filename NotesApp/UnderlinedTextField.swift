//
//  UnderlinedTextField.swift
//  NotesApp
//
//  Created by Сашок on 27.03.2022.
//

import Foundation
import UIKit

@IBDesignable class UnderlinedTextField: UITextField {
    // MARK: - Inspectable properties
    @IBInspectable var lineWidth: CGFloat = 2 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var lineColor: UIColor = UIColor.lightGray {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var lineGap: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Override properties
    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width,
               height: super.intrinsicContentSize.height + lineWidth + lineGap)
    }
    
    // MARK: - Private properties
    private let underlineLayer = CALayer()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUnderlineLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUnderlineLayer()
    }
    
    // MARK: - Override methods
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUnderline()
    }
    
    // MARK: - Private methods
    private func setupUnderlineLayer() {
        layer.insertSublayer(underlineLayer, at: 0)
    }
    
    private func updateUnderline() {
        underlineLayer.frame = CGRect(x: 0.0, y: bounds.height - lineWidth, width: bounds.width, height: lineWidth)
        underlineLayer.backgroundColor = lineColor.cgColor
    }
}
