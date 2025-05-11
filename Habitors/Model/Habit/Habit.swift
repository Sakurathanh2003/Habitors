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
    var goalValue: Double
    var isTemplate: Bool
    var startedDate: Date
    
    var frequency: Frequency
    var reminder: [Time] = []
    
    init(id: String, 
         name: String,
         icon: String,
         goalUnit: GoalUnit,
         goalValue: Double,
         isTemplate: Bool,
         startedDate: Date = Date(),
         frequency: Frequency = .init(),
         reminder: [Time] = []
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.goalUnit = goalUnit
        self.goalValue = goalValue
        self.isTemplate = isTemplate
        self.startedDate = startedDate
        self.frequency = frequency
        self.reminder = reminder
    }
}

// MARK: - Realm
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
        object.reminder = self.reminder.map({ $0.rlmValue() }).joined(separator: "|")
       
        return object
    }
    
    convenience init(rlm: RlmHabit) {
        var frequency: Frequency
    
        if let data = rlm.frequency.data(using: .utf8), let object = try? JSONDecoder().decode(Frequency.self, from: data){
            frequency = object
        } else {
            frequency = .init()
        }
        
        let reminder = rlm.reminder.split(separator: "|")
                                    .compactMap({ String($0)})
                                    .map({ Time(rlmValue: $0) })
        self.init(id: rlm.id, name: rlm.name, icon: rlm.icon,
                  goalUnit: rlm.goalUnit, goalValue: rlm.goalValue,
                  isTemplate: rlm.isTemplate,
                  startedDate: rlm.startDate,
                  frequency: frequency,
                  reminder: reminder
        )
    }
}

extension Habit {
    var records: [HabitRecord] {
        return HabitRecordDAO.shared.getRecord(habitID: self.id)
    }
}
