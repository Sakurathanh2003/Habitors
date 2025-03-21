//
//  Habit.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import Foundation

struct Habit: Codable {
    var id: String
    var name: String
    var icon: String
    var goalUnit: GoalUnit
    var goalValue: Int
    var color: Int?
    var isTemplate: Bool
    
    var frequency: Frequency
    var reminder: [Time]
    
    init(id: String,
         name: String,
         icon: String,
         goalUnit: GoalUnit,
         goalValue: Int,
         color: Int? = nil,
         isTemplate: Bool,
         frequency: Frequency = .init(),
         reminder: [Time] = []
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.goalUnit = goalUnit
        self.goalValue = goalValue
        self.color = color
        self.isTemplate = isTemplate
        self.frequency = frequency
        self.reminder = reminder
    }
}

