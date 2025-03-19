//
//  HabitCategory.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import Foundation

struct HabitCategory: Codable {
    var id: String
    var name: String
    var icon: String
    var description: String
    var items: [Habit]
    
    init(id: String, name: String, icon: String, description: String, items: [Habit]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.description = description
        self.items = items
    }
}

