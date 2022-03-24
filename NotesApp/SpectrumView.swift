//
//  SpectrView.swift
//  NotesApp
//
//  Created by Сашок on 24.03.2022.
//

import UIKit

@IBDesignable
class SpectrumView: UIView
{
    @IBInspectable var elementSize: CGFloat = CGFloat(1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawSpectrum(rect)
    }
    
    private func drawSpectrum(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        for y in stride(from: 0.0 ,to: rect.height, by: elementSize) {
            let saturation = (rect.height - y) / rect.height
            let brightness = CGFloat(1.0)
            
            for x in stride(from: 0.0 ,to: rect.width, by: elementSize) {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: elementSize, height: elementSize))
            }
        }
    }
}
