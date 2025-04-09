//
//  AppConst.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import Foundation

class AppConst {
    static let habitCategories: [HabitCategory] = [
        HabitCategory(id: "appleHealth", name: "Apple Health", icon: "<3", description: "Health habits are linked witth Apple Health App", items: [
            .init(id: "Walk", name: "Walk", icon: "🚶🏻‍♀️‍➡️", goalUnit: .steps, goalValue: 1000, isTemplate: true),
            .init(id: "Exercise", name: "Exercise", icon: "🏃🏻", goalUnit: .exerciseTime, goalValue: 2, isTemplate: true)
        ]),
        HabitCategory(id: "health", name: "Health", icon: "<3", description: "Health habits are linked witth Apple Health App", items: [
            .init(id: "Walk", name: "Walk", icon: "🚶🏻‍♀️‍➡️", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Stand", name: "Stand", icon: "🧍🏻‍♀️", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Cycling", name: "Cycling", icon: "🚴🏻", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Burn Calorie", name: "Burn Calorie", icon: "🔥", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Exercise", name: "Exercise", icon: "🏃🏻", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Meditation", name: "Meditation", icon: "🧘🏻", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Drink water", name: "Drink water", icon: "💧", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Workout", name: "Workout", icon: "💪🏻", goalUnit: .steps, goalValue: 10000, isTemplate: true)
        ]),
        HabitCategory(id: "sport", name: "Sport", icon: "", description: "Exercise and fitness related habits", items: [
            .init(id: "Walk", name: "Walk", icon: "🚶🏻‍♀️‍➡️", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Run", name: "Run", icon: "🚶🏻‍♀️‍➡️", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Stretch", name: "Stretch", icon: "🚶🏻‍♀️‍➡️", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Stand", name: "Stand", icon: "🧍🏻‍♀️", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Yoga", name: "Yoga", icon: "🧍🏻‍♀️", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Cycling", name: "Cycling", icon: "🚴🏻", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Swim", name: "Swim", icon: "🚴🏻", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Burn Calorie", name: "Burn Calorie", icon: "🔥", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Exercise", name: "Exercise", icon: "🏃🏻", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Workout", name: "Workout", icon: "💪🏻", goalUnit: .steps, goalValue: 10000, isTemplate: true),
            .init(id: "Anaerobic", name: "Anaerobic", icon: "💪🏻", goalUnit: .steps, goalValue: 10000, isTemplate: true)
        ])
    ]
}
