//
//  CalendarViewModel.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import Foundation
import SwiftUI

enum CalendarMode {
    case chooseDays
    case chooseDay
    case analytic
}

class CalendarViewModel: ObservableObject {
    @Published var currentMonth = Date()
    @Published var selectedDate = [Date]()
    @Published var daysInMonth = [Date]()
    @Published var habits: [Habit] = []

    let mode: CalendarMode
    
    init(mode: CalendarMode, selectedDate: [Date] = [], habits: [Habit] = []) {
        self.selectedDate = selectedDate
        self.mode = mode
        self.habits = habits
        
        if let firstDate = selectedDate.first {
            self.currentMonth = firstDate
        } else {
            self.currentMonth = Date()
        }
        
        updateDaysInMonth()
    }
    
    var records: [HabitRecord] {
        return habits.flatMap({ $0.records })
    }
    
    var month: String {
        return currentMonth.format("MMMM yyyy")
    }
    
    func isSameMonth(_ day: Date) -> Bool {
        return day.isSameMonth(as: currentMonth)
    }
    
    func isSelected(_ day: Date) -> Bool {
        return selectedDate.contains(where: { $0.isSameDay(date: day) })
    }
    
    func chooseDay(_ day: Date) {
        switch mode {
        case .chooseDays:
            
            if selectedDate.contains(where: { $0.isSameDay(date: day)}) {
                selectedDate.removeAll(where: { $0.isSameDay(date: day)})
            } else {
                selectedDate.append(day)
            }
            
            self.selectedDate.sort()
        case .chooseDay:
            selectedDate.removeAll()
            selectedDate.append(day)
        case .analytic:
            break
        }
    }
    
    func updateNextMonth() {
        self.currentMonth = self.currentMonth.nextMonth
        updateDaysInMonth()
    }
    
    func updatePreviousMonth() {
        self.currentMonth = self.currentMonth.previousMonth
        updateDaysInMonth()
    }
    
    private func updateDaysInMonth() {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        var days = range.map { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
        }
        
        while let day = days.first, !day.isStartOfWeek {
            days.insert(day.previousDay, at: 0)
        }
        
        while let day = days.last, !day.isEndOfWeek {
            days.append(day.nextDay)
        }
        
        self.daysInMonth = days
    }
    
    func percentInDate(_ date: Date) -> Double {
        let habitsInDay = self.habits.filter { date.isDateValid($0) }
        var percents: Double = 0
        for habit in habitsInDay {
            if let record = habit.records.first(where: { $0.date.isSameDay(date: date) }) {
                percents += record.completedPercent
            }
        }
        
        if habitsInDay.isEmpty {
            return 0
        }
        
        return percents/Double(habitsInDay.count)
    }
}


#Preview {
    HomeView(viewModel: .init())
//    CalendarDialog(isAllowSelectedMore: false, selectedDate: [], cancelAction: {
//
//    }, doneAction: { dates in
//
//    })
}
