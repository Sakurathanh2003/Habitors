//
//  Text+Extension.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import Foundation
import SwiftUI

extension Font {
    static func fontMedium(_ size: CGFloat) -> Font {
        return Font.custom("Gilroy-Medium", size: size)
    }
    
    static func fontSemiBold(_ size: CGFloat) -> Font {
        return Font.custom("Gilroy-SemiBold", size: size)
    }
    
    static func fontRegular(_ size: CGFloat) -> Font {
        return Font.custom("Gilroy-Regular", size: size)
    }
    
    static func fontBold(_ size: CGFloat) -> Font {
        return Font.custom("SVN-Gilroy Bold", size: size)
    }
}

extension Text {
    func fontRegular(_ size: CGFloat) -> Text {
        self.font(.fontRegular(size))
    }
    
    func fontBold(_ size: CGFloat) -> Text {
        self.font(.fontBold(size))
    }
    
    func fontSemiBold(_ size: CGFloat) -> Text {
        self.font(.fontSemiBold(size))
    }
    
    func fontMedium(_ size: CGFloat) -> Text {
        self.font(.fontMedium(size))
    }
    
    func autoresize(_ numberOfLine: Int) -> some View {
        self.lineLimit(numberOfLine)
            .scaledToFit()
            .minimumScaleFactor(0.1)
    }
}

extension View {
    func fontRegular(_ size: CGFloat) -> some View {
        self.font(.fontRegular(size))
    }
    
    func fontBold(_ size: CGFloat) -> some View {
        self.font(.fontBold(size))
    }
    
    func fontSemiBold(_ size: CGFloat) -> some View {
        self.font(.fontSemiBold(size))
    }
    
    func fontMedium(_ size: CGFloat) -> some View {
        self.font(.fontMedium(size))
    }
}
