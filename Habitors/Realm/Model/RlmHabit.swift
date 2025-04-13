//
//  RlmHabit.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 26/3/25.
//

import UIKit
import RealmSwift
import Realm

final class RlmHabit: Object {
    @Persisted(primaryKey: true) var id: String!
    @Persisted var name: String!
    @Persisted var icon: String!
    @Persisted var goalUnit: GoalUnit!
    @Persisted var goalValue: Double = 0
    
    @Persisted var frequency: String!
    @Persisted var startDate: Date = Date()
    @Persisted var isTemplate: Bool!
    
    // Quan hệ 1-N: Một thói quen có nhiều bản ghi
    @Persisted var records = List<RlmHabitRecord>()
}

extension Habit {
    func rlmObject() -> RlmHabit {
        let object = RlmHabit()
        object.id = self.id
        object.name = self.name
        object.icon = self.icon
        object.goalUnit = self.goalUnit
        object.goalValue = self.goalValue
        object.frequency = self.frequency.json
        object.startDate = self.startedDate
        object.isTemplate = self.isTemplate
        
        for record in self.records {
            object.records.append(RlmHabitRecord(from: record))
        }
       
        return object
    }
}                                      
                                          
