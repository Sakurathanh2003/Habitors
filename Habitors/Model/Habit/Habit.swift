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
}
