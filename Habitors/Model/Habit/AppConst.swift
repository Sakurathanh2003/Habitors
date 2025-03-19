//
//  AppConst.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import Foundation

class AppConst {
    static let habitCategories: [HabitCategory] = [
        HabitCategory(id: "health", name: "Health", icon: "<3", description: "Health habits are linked witth Apple Health App", items: [
            .init(id: "", name: "Walk", icon: "🚶🏻‍♀️‍➡️", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Stand", icon: "🧍🏻‍♀️", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Cycling", icon: "🚴🏻", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Burn Calorie", icon: "🔥", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Exercise", icon: "🏃🏻", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Meditation", icon: "🧘🏻", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Drink water", icon: "💧", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Workout", icon: "💪🏻", goalUnit: .steps, goalValue: 10000)
        ]),
        HabitCategory(id: "sport", name: "Sport", icon: "", description: "Exercise and fitness related habits", items: [
            .init(id: "", name: "Walk", icon: "🚶🏻‍♀️‍➡️", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Run", icon: "🚶🏻‍♀️‍➡️", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Stretch", icon: "🚶🏻‍♀️‍➡️", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Stand", icon: "🧍🏻‍♀️", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Yoga", icon: "🧍🏻‍♀️", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Cycling", icon: "🚴🏻", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Swim", icon: "🚴🏻", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Burn Calorie", icon: "🔥", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Exercise", icon: "🏃🏻", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Workout", icon: "💪🏻", goalUnit: .steps, goalValue: 10000),
            .init(id: "", name: "Anaerobic", icon: "💪🏻", goalUnit: .steps, goalValue: 10000)
        ])
    ]
}
//extension HabitType {
//    var listDefault: [Habit] {
//        switch self {
//        case .health:
//            [

//            ]
//        case .sport:
//            [
//                .init(id: "", name: "Walk", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Run", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Stretch", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Sttand", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Yoga", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Cycling", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Swim", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Burn Calorie", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Exercise", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Workout", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Aerobic", type: .health, icon: "🚶🏻‍♀️‍➡️")
//            ]
//        case .lifestyle:
//            [
//                .init(id: "", name: "Track expenses", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Save money", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Eat less sugar", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Meditation", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Read a book", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Learning", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Review today", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Mind Clearing", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Drink water", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Eat fruit", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Eatt vege", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "No sugar", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Sleep early", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Laugh out loud", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Eat Low-Fatt", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Eat an apple", type: .health, icon: "🚶🏻‍♀️‍➡️"),
//                .init(id: "", name: "Eat Breakfast", type: .health, icon: "🚶🏻‍♀️‍➡️")
//            ]
//        case .time:
//            <#code#>
//        case .quit:
//            <#code#>
//        case .custom:
//            <#code#>
//        }
//    }
//}

