//
//  Frequency.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 20/3/25.
//

import Foundation

@objc class Frequency: Codable {
    var type: RepeatType
    var daily: Daily
    var weekly: Weekly
    var monthly: TimeOfMonth
    
    init(type: RepeatType, daily: Daily, weekly: Weekly, monthly: TimeOfMonth) {
        self.type = type
        self.daily = daily
        self.weekly = weekly
        self.monthly = monthly
    }
    
    init() {
        self.type = .daily
        self.daily = .init(selectedDays: [2, 3, 4, 5, 6, 7, 8])
        self.weekly = .init(frequency: 2)
        self.monthly = .middle
    }
    
    enum RepeatType: String, CaseIterable, Codable {
        case daily
        case weekly
        case monthly
    }
    
    struct Daily: Codable {
        var selectedDays: [Int]
        
        init(selectedDays: [Int]) {
            self.selectedDays = selectedDays
        }
    }
    
    struct Weekly: Codable {
        var frequency: Int
        
        init(frequency: Int) {
            self.frequency = frequency
        }
    }
    
    enum TimeOfMonth: String, CaseIterable ,Codable {
        case beginning
        case middle
        case end
        
        var description: String {
            switch self {
            case .beginning:
                "1st day of month to 10th day of month"
            case .middle:
                "11th day of month to 20th day of month"
            case .end:
                "21st day of month to end of month"
            }
        }
    }
}

extension Frequency {
    var description: String {
        var text = ""
        text += type.rawValue.capitalized
        
        switch type {
        case .daily:
            text += " - \(daily.selectedDays.count) days"
        case .weekly:
            text += " - \(weekly.frequency) days"
        case .monthly:
            text += " - \(monthly.rawValue.capitalized)"
        }
        
        return text
    }
}

