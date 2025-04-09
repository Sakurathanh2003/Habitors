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
    var value: Int? // Số
    var createdAt: Date = Date()
    
    init(id: String, habitID: String, date: Date, status: String, value: Int? = nil, createdAt: Date) {
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
}
