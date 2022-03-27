//
//  UIColor + Extension.swift
//  NotesApp
//
//  Created by Сашок on 27.03.2022.
//

import UIKit

extension UIColor {
    convenience init(hexValue: UInt32) {
        let alpha = CGFloat((hexValue >> 24) & 0xFF) / 255.0
        let red = CGFloat((hexValue >> 16) & 0xFF) / 255.0
        let green = CGFloat((hexValue >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hexValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    var hexValue: UInt32 {
        let currentColor = CIColor(color: self)
        
        let red = UInt32(currentColor.red * 255.0)
        let green = UInt32(currentColor.green * 255.0)
        let blue = UInt32(currentColor.blue * 255.0)
        let alpha = UInt32(currentColor.alpha * 255.0)
        
        return UInt32((alpha << 24) + (red << 16) + (green << 8) + blue)
    }
}
