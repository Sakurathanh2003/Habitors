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
    
    var startOfDay: Date {
        let dateComponents = DateComponents(year: year, month: month, day: day)
        let targetDate = calendar.date(from: dateComponents)!
        return calendar.startOfDay(for: targetDate)
    }
    
    var endOfDay: Date {
        return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay)!
    }
    
    // Check nếu là ngày cuối tuần (Chủ nhật)
    var isEndOfWeek: Bool {
        let weekday = calendar.component(.weekday, from: self)
        return weekday == (calendar.firstWeekday + 5) % 7 + 1
    }
    
    var isToday: Bool {
        return calendar.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        return calendar.isDateInTomorrow(self)
    }
    
    var isFutureDay: Bool {
        let today = Date().startOfDay
        let compareDate = self.startOfDay
        return compareDate > today
    }
    
    // Lùi lại 1 ngày
    var previousDay: Date {
        return calendar.date(byAdding: .day, value: -1, to: self) ?? self
    }
    
    // Tiến lên 1 ngày
    var nextDay: Date {
        return calendar.date(byAdding: .day, value: 1, to: self) ?? self
    }
    
    var nextYear: Date {
        return calendar.date(byAdding: .year, value: 1, to: self) ?? self
    }
    
    var previousYear: Date {
        return calendar.date(byAdding: .year, value: -1, to: self) ?? self
    }
    
    var nextMonth: Date {
        return calendar.date(byAdding: .month, value: 1, to: self) ?? self
    }
    
    var previousMonth: Date {
        return calendar.date(byAdding: .month, value: -1, to: self) ?? self
    }
    
    var year: Int {
        return calendar.component(.year, from: self)
    }
    
    var month: Int {
        return calendar.component(.month, from: self)
    }
    
    var day: Int {
        return calendar.component(.day, from: self)
    }
    
    var hour: Int {
        return calendar.component(.hour, from: self)
    }
    
    var minute: Int {
        return calendar.component(.minute, from: self)
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

// MARK: - Next Time
extension Date {
    func nextWeekday(_ weekday: Int) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .weekday], from: self)
        
        // Tính số ngày cần cộng để đến ngày weekday
        var daysToAdd = weekday - components.weekday!
        
        // Nếu daysToAdd < 0 thì có nghĩa là ngày weekday đã qua trong tuần này
        if daysToAdd < 0 {
            daysToAdd += 7 // Cộng thêm 7 ngày để đến tuần sau
        } else if daysToAdd == 0 {
            // Nếu ngày hiện tại là đúng ngày weekday bạn muốn, giữ nguyên không cộng thêm ngày
            return self
        }
        
        // Thêm số ngày cần thiết vào ngày hiện tại
        components.day! += daysToAdd
        
        return calendar.date(from: components)
    }
}
