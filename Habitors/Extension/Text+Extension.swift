//
//  Text+Extension.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import Foundation
import SwiftUI

extension Text {
    func gilroyRegular(_ size: CGFloat) -> Text {
        self.font(.custom("Gilroy-Regular", size: size))
    }
    
    func gilroyBold(_ size: CGFloat) -> Text {
        self.font(.custom("Gilroy-Bold", size: size))
    }
    
    func gilroySemiBold(_ size: CGFloat) -> Text {
        self.font(.custom("Gilroy-SemiBold", size: size))
    }
    
    func gilroyMedium(_ size: CGFloat) -> Text {
        self.font(.custom("Gilroy-Medium", size: size))
    }
    
    func autoresize(_ numberOfLine: Int) -> some View {
        self.lineLimit(numberOfLine)
            .scaledToFit()
            .minimumScaleFactor(0.1)
    }
}
