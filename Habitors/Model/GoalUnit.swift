//
//  GoalUnit.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import Foundation
import RealmSwift
import HealthKit

enum GoalUnit: String, Codable, PersistableEnum, CaseIterable {
    case count
    
   
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
    
    // Đơn vị liên quan đến Apple Health
    case exerciseTime = "minute"
    case steps
    
    static func custom() -> [GoalUnit] {
        [.count, .kcal, .lbs, .ml, .usoz, .mile, .km, .m, .secs, .min, .hours]
    }
}

extension GoalUnit {
    var healthType: HKQuantityType? {
        switch self {
        case .steps: HKQuantityType(.stepCount)
        case .exerciseTime: HKQuantityType(.appleExerciseTime)
        default: nil
        }
    }
    
    var permissionMessage: String {
        switch self {
        case .steps: "Bạn cần cấp quyền cho ứng dụng truy cập và đọc số lượng bước"
        case .exerciseTime: "Bạn cần cấp quyền cho ứng dụng truy cập và đọc thời gian exercise"
        default: ""
        }
    }
}
