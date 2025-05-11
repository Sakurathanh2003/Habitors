//
//  HabitRecord.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 26/3/25.
//

import Foundation

class HabitRecord: Codable, ObservableObject {
    var id: String
    var habitID: String // Liên kết với Habit
    var date: Date
    var value: Double = 0 // Số
    
    init(id: String, habitID: String, date: Date, value: Double = 0) {
        self.id = id
        self.habitID = habitID
        self.date = date
        self.value = value
    }
    
    init(from rlm: RlmHabitRecord) {
        self.id = rlm.id.stringValue
        self.habitID = rlm.habitID
        self.date = rlm.date
        self.value = rlm.value
    }
    
    var habit: Habit? {
        HabitDAO.shared.getAll().first(where: { $0.id == habitID })
    }
    
    func replaceValue(_ value: Double) -> HabitRecord {
        return .init(id: id, habitID: habitID, date: date, value: value)
    }
}

extension HabitRecord {
    // Mục tiêu hoàn thành
    var goalValue: Double {
        return habit?.goalValue ?? 1
    }
    
    // Đơn vị
    var unit: GoalUnit {
        return habit?.goalUnit ?? .count
    }
    
    // Cần bao nhiêu nữa để đạt được mục tiêu (base unit)
    var baseRemainingValue: Double {
        unit.convertToBaseUnit(from: goalValue) - value
    }
    
    // Cần bao nhiêu nữa để đạt được mục tiêu (unit)
    var remainingValue: Double {
        unit.convertToUnit(from: baseRemainingValue)
    }
    
    // Đã hoàn thành hay chưa
    var isCompleted: Bool {
        baseRemainingValue <= 0
    }
    
    // Hoàn thành bao nhiêu phần trăm
    var completedPercent: Double {
        min(max(value / unit.convertToBaseUnit(from: goalValue), 0), 1)
    }
}
