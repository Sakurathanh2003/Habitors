//
//  MoodRecord.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 18/4/25.
//
import Foundation
import SwiftUI

struct MoodRecord {
    var id: String
    var createdDate: Date
    var value: Mood
}

enum Mood: String, CaseIterable {
    case angry
    case upset
    case sad
    case good
    case happy
    case spectacular
    
    var thumbnailCount: Int {
        switch self {
        case .angry: 3
        case .upset: 3
        case .sad: 3
        case .good: 3
        case .happy: 3
        case .spectacular: 4
        }
    }
    
    var adjs: [String] {
        switch self {
        case .angry:
            []
        case .upset:
            []
        case .sad:
            []
        case .good:
            []
        case .happy:
            []
        case .spectacular:
            []
        }
    }
    
    var color: Color {
        return Color(self.rawValue)
    }
}
