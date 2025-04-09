//
//  Habit.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import Foundation
import SwiftUI

class Habit: Codable, ObservableObject {
    var id: String
    var name: String
    var icon: String
    var goalUnit: GoalUnit
    var goalValue: Int
    var isTemplate: Bool
    var startedDate: Date
    
    var frequency: Frequency
    var records: [HabitRecord] = []
    
    init(id: String, 
         name: String,
         icon: String,
         goalUnit: GoalUnit,
         goalValue: Int,
         isTemplate: Bool,
         startedDate: Date = Date(),
         frequency: Frequency = .init(),
         records: [HabitRecord] = []) {
        self.id = id
        self.name = name
        self.icon = icon
        self.goalUnit = goalUnit
        self.goalValue = goalValue
        self.isTemplate = isTemplate
        self.startedDate = startedDate
        self.frequency = frequency
        self.records = records
    }
    
    init(rlm: RlmHabit) {
        self.id = rlm.id
        self.name = rlm.name
        self.icon = rlm.icon
        self.goalUnit = rlm.goalUnit
        self.goalValue = rlm.goalValue
        self.isTemplate = rlm.isTemplate
        
        if let data = rlm.frequency.data(using: .utf8), let object = try? JSONDecoder().decode(Frequency.self, from: data){
            self.frequency = object
        } else {
            self.frequency = .init()
        }
        
        self.startedDate = rlm.startDate
        self.records = rlm.records.map({ HabitRecord(id: $0.id.stringValue, habitID: self.id, date: $0.date, status: $0.status, value: $0.value,createdAt: $0.createdAt)})
    }
}

extension Habit {
    func isCompleted(_ date: Date) -> Bool {
        if let record = records.first(where: { $0.createdAt.isSameDay(date: date) }) {
            return (record.value ?? 0) >= goalValue
        }
        
        return false
    }
}
