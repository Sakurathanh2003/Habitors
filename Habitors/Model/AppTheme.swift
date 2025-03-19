//
//  AppTheme.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 18/3/25.
//

import Foundation
import SwiftUI

enum AppTheme {
    case theme1
    case theme2
    case theme3
    case theme4
}

// MARK: - Background
extension AppTheme {
    var backgroundColor: Color {
        switch self {
        case .theme1, .theme2: Color.white
        case .theme3, .theme4: Color.black
        }
    }
}
