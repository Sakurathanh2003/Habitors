//
//  Double+Extension.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 12/4/25.
//

import UIKit

extension Double {
    var text: String {
        if self == floor(self) {
            return String(format: "%.0f", self)  // Hiển thị dưới dạng số nguyên
        }
        
        let stringValue = String(describing: self)
        return stringValue
    }
    
    func textWithDecimal(_ decimal: Int) -> String {
        if self == floor(self) {
            return String(format: "%.0f", self)  // Hiển thị dưới dạng số nguyên
        }
        
        return String(format: "%.\(decimal)f", self)
    }
}

extension CGFloat {
    func textWithDecimal(_ decimal: Int) -> String {
        if self == floor(self) {
            return String(format: "%.0f", self)  // Hiển thị dưới dạng số nguyên
        }
        
        return String(format: "%.\(decimal)f", self)
    }
}

