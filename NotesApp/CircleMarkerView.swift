//
//  CircleSelectorView.swift
//  NotesApp
//
//  Created by Сашок on 24.03.2022.
//

import UIKit

@IBDesignable class CircleMarkerView: UIView {
    // MARK: - Inspectable properties
    @IBInspectable var markerColor: UIColor = UIColor.white {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var markerPercentage: CGFloat {
        get {
            radiusMultiplier * 100
        }
        set {
            radiusMultiplier = newValue / 100
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 4 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var showMarker: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Private properties
    private var radiusMultiplier: CGFloat = 0.7
    private var markerFillColor = UIColor.clear
    private let markerLayer = CAShapeLayer()

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
        updateMArker()
    }
    
    // MARK: - Private methods
    private func setupMarkerLayer() {
        layer.insertSublayer(markerLayer, at: 0)
    }
    
    private func updateMArker() {
        markerLayer.isHidden = !showMarker
        
        markerLayer.frame = bounds
        markerLayer.lineWidth = lineWidth
        markerLayer.strokeColor = markerColor.cgColor
        markerLayer.fillColor = markerFillColor.cgColor
        markerLayer.path = getCirclePath(in: bounds, lineWidth: lineWidth, multiplier: radiusMultiplier).cgPath
    }
}

// MARK: - Reusable functionality
extension CircleMarkerView {
    func getCirclePath(in rect: CGRect, lineWidth: CGFloat, multiplier: CGFloat) -> UIBezierPath {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let side = min(rect.width, rect.height)
        let radius = multiplier * (side - lineWidth) / 2
        
        return UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
    }
}
