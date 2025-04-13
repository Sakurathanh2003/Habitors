//
//  Calendar+Extension.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import Foundation

extension Calendar {
    func getDatesInMonth() -> [Date] {
        let today = Date()
        
        // Lấy khoảng thời gian của tháng hiện tại
        let range = self.range(of: .day, in: .month, for: today)!
        
        // Lấy ngày đầu tiên của tháng
        let startOfMonth = self.date(from: self.dateComponents([.year, .month], from: today))!
        
        // Tạo danh sách các ngày
        return range.map { day -> Date in
            return self.date(byAdding: .day, value: day - 1, to: startOfMonth)!
        }
    }
    
    func getFullWeeksOfYear(year: Int) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Thứ Hai là ngày đầu tuần (ISO 8601)

        // 1. Get first day of year
        guard let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) else {
            return []
        }

        // 2. Find previous Monday before or on Jan 1st
        let startWeekday = calendar.component(.weekday, from: startOfYear)
        let daysToSubtract = (startWeekday + 5) % 7 // Convert to 0 = Monday
        let adjustedStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfYear)!

        // 3. Find next Sunday after or on Dec 31st
        let endWeekday = calendar.component(.weekday, from: endOfYear)
        let daysToAdd = (8 - endWeekday) % 7
        let adjustedEnd = calendar.date(byAdding: .day, value: daysToAdd, to: endOfYear)!

        // 4. Generate all dates from adjustedStart to adjustedEnd
        var dates: [Date] = []
        var current = adjustedStart
        while current <= adjustedEnd {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        return dates
    }
    
    func getDatesInWeek(containing date: Date) -> [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        // Tính offset từ thứ hai (weekday = 2)
        let diff = (weekday + 5) % 7
        let startOfWeek = calendar.date(byAdding: .day, value: -diff, to: calendar.startOfDay(for: date))!
        
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    func getDatesInMonth(containing date: Date) -> [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    func getDatesInMonth(year: Int, month: Int) -> [Date] {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month)
        guard let startOfMonth = calendar.date(from: components) else { return [] }
        
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
}
