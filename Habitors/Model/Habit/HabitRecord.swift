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
    var status: String // "completed" hoặc "missed"
    var value: Double = 0 // Số
    var createdAt: Date = Date()
    
    init(id: String, habitID: String, date: Date, status: String, value: Double = 0, createdAt: Date) {
        self.id = id
        self.habitID = habitID
        self.date = date
        self.status = status
        self.value = value
        self.createdAt = createdAt
    }
    
    init(from rlm: RlmHabitRecord) {
        self.id = rlm.id.stringValue
        self.habitID = rlm.habit.first?.id ?? ""
        self.date = rlm.date
        self.status = rlm.status
        self.value = rlm.value
        self.createdAt = rlm.createdAt
        self.status = rlm.status
    }
    
    var habit: Habit? {
        HabitDAO.shared.getAll().first(where: { $0.id == habitID })
    }
    
    var isExits: Bool {
        (HabitRecordDAO.shared.getHabitRecord(id: self.id) != nil)
    }
    
    func replaceValue(_ value: Double) -> HabitRecord {
        return .init(id: id, habitID: habitID, date: date, status: status, value: value, createdAt: createdAt)
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
