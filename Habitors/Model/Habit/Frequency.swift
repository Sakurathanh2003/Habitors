//
//  Frequency.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 20/3/25.
//

import Foundation

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
    
    struct Monthly: Codable {
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
        text += Translator.translate(key: type.rawValue.capitalized)
        
        switch type {
        case .daily:
            text += " - \(daily.selectedDays.count) " + Translator.translate(key: "days")
        case .weekly:
            text += " - \(weekly.frequency) " + Translator.translate(key: "times")
        case .monthly:
            text += " - " + Translator.translate(key: monthly.type.rawValue.capitalized)
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

