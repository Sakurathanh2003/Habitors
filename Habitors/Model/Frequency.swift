//
//  Frequency.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 20/3/25.
//

import Foundation

class Time: NSObject, Codable {
    var hour: Int
    var minutes: Int
    
    init(hour: Int, minutes: Int) {
        self.hour = hour
        self.minutes = minutes
    }
    
    static func morning() -> Time {
        return .init(hour: 8, minutes: 00)
    }
    
    static func afternoon() -> Time {
        return .init(hour: 13, minutes: 00)
    }
    
    static func evening() -> Time {
        return .init(hour: 19, minutes: 00)
    }
    
    override var description: String {
        return String(format: "%02d:%02d", hour, minutes)
    }
    
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.hour == rhs.hour && lhs.minutes == rhs.minutes
    }
}

class Frequency: Codable {
    var id: String
    var type: RepeatType
    var daily: Daily
    var weekly: Weekly
    var monthly: Monthly
    
    init(type: RepeatType, daily: Daily, weekly: Weekly, monthly: Monthly) {
        self.id = UUID().uuidString
        self.type = type
        self.daily = daily
        self.weekly = weekly
        self.monthly = monthly
    }
    
    init() {
        self.id = UUID().uuidString
        self.type = .daily
        self.daily = .init(selectedDays: [2, 3, 4, 5, 6, 7, 8])
        self.weekly = .init(frequency: 2)
        self.monthly = .init(type: .beginning)
    }
    
    enum RepeatType: String, CaseIterable, Codable {
        case daily
        case weekly
        case monthly
    }
    
    struct Daily: Codable {
        var reminder: [Time] = []
        var selectedDays: [Int]
        
        init(selectedDays: [Int]) {
            self.selectedDays = selectedDays
        }
    }
    
    struct Weekly: Codable {
        var reminder: [Time] = []
        var frequency: Int
        
        init(frequency: Int) {
            self.frequency = frequency
        }
    }
    
    struct Monthly: Codable {
        var reminder: [Time] = []
        var type: TimeOfMonth
        
        init(type: TimeOfMonth) {
            self.type = type
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
            text += " - \(monthly.type.rawValue.capitalized)"
        }
        
        return text
    }
    
    var json: String {
        let jsonData = try? JSONEncoder().encode(self)
        return jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }
}

extension Frequency.Daily {
    func isSelectedDay(_ day: Date) -> Bool {
        var today = day.calendar.component(.weekday, from: day)
        
        if today == 1 {
            today += 7
        }
       
        return self.selectedDays.contains(today)
    }
}

extension Frequency.Monthly {
    func isSelectedDay(_ date: Date) -> Bool {
        switch self.type {
        case .beginning:
            return date.day <= 10
        case .end:
            return date.day >= 21
        case .middle:
            return 11 <= date.day && date.day <= 21
        }
    }
}

