//
//  Date+Extension.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import Foundation

extension Date {
    var calendar: Calendar {
        return Calendar.current
    }
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // Check nếu là ngày bắt đầu của tuần (Thứ 2)
    var isStartOfWeek: Bool {
        let weekday = calendar.component(.weekday, from: self)
        return weekday == calendar.firstWeekday
    }
    
    // Check nếu là ngày cuối tuần (Chủ nhật)
    var isEndOfWeek: Bool {
        let weekday = calendar.component(.weekday, from: self)
        return weekday == (calendar.firstWeekday + 5) % 7 + 1
    }
    
    var isToday: Bool {
        return calendar.isDateInToday(self)
    }
    
    // Lùi lại 1 ngày
    var previousDay: Date {
        return calendar.date(byAdding: .day, value: -1, to: self) ?? self
    }
    
    // Tiến lên 1 ngày
    var nextDay: Date {
        return calendar.date(byAdding: .day, value: 1, to: self) ?? self
    }
    
    var nextMonth: Date {
        return calendar.date(byAdding: .month, value: 1, to: self) ?? self
    }
    
    var previousMonth: Date {
        return calendar.date(byAdding: .month, value: -1, to: self) ?? self
    }
    
    var day: Int {
        return calendar.component(.day, from: self)
    }
    
    func isSameMonth(as otherDate: Date) -> Bool {
        let components1 = calendar.dateComponents([.year, .month], from: self)
        let components2 = calendar.dateComponents([.year, .month], from: otherDate)
        return components1 == components2
    }
    
    func isSameDay(date: Date) -> Bool {
        calendar.isDate(self, inSameDayAs: date)
    }
}
