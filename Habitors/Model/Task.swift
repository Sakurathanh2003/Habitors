//
//  Task.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import Foundation

class Task {
    var id: String
    var name: String
    var isCompleted: Bool
    var date: Date
    
    init(name: String, isCompleted: Bool, date: Date) {
        self.id = UUID().uuidString
        self.name = name
        self.isCompleted = isCompleted
        self.date = date
    }
}

class Time {
    var hour: Int
    var minutes: Int
    
    init(hour: Int, minutes: Int) {
        self.hour = hour
        self.minutes = minutes
    }
    
    var description: String {
        return String(format: "%02d:%02d", hour, minutes)
    }
}
