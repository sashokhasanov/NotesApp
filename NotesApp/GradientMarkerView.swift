//
//  CustomColorView.swift
//  NotesApp
//
//  Created by Сашок on 24.03.2022.
//

import UIKit

class GradientMarkerView: CircleMarkerView {
    // MARK: - Inspectable properties
    @IBInspectable var gradientMarkerPercentage: CGFloat {
        get {
            gradientRadiusMultiplier * 100
        }
        set {
            gradientRadiusMultiplier = newValue / 100
        }
    }
    
    @IBInspectable var gradientLineWidth: CGFloat = 5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var showGradientMarker: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Private properties
    private var gradientRadiusMultiplier: CGFloat = 1.0
    private var gradientLayer = CAGradientLayer()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMarkerLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupMarkerLayer()
    }
    
    // MARK: - Override methods
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
    }
    
    // MARK: - Private methods
    private func updateGradient() {
        gradientLayer.frame = bounds
        gradientLayer.mask = makeMaskLayer()
    }
    
    private func setupMarkerLayer() {
        gradientLayer.type = .conic
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [UIColor.red,
                                UIColor.orange,
                                UIColor.yellow,
                                UIColor.green,
                                UIColor.blue,
                                UIColor.purple].map { $0.cgColor }
        
        layer.insertSublayer(gradientLayer, at: 1)
    }
    
    private func makeMaskLayer() ->CALayer {
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.lineWidth = gradientLineWidth
        maskLayer.path =
            getCirclePath(in: bounds, lineWidth: gradientLineWidth, multiplier: gradientRadiusMultiplier).cgPath
        
        return maskLayer
    }
}
