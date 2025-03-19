//
//  GoalUnit.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import Foundation

enum GoalUnit: String, Codable, CaseIterable {
    case count
    case steps
   
    case kcal
    case lbs
    
    case ml
    case usoz = "US oz"
    
    // Đơn vị đo đường
    case mile
    case km
    case m
    
    // Đơn vị đo thời gian
    case secs
    case min
    case hours
}
