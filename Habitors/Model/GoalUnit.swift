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
    case liter
    
    // Đơn vị đo đường
    case mile
    case km
    case m
    
    // Đơn vị đo thời gian
    case secs
    case min
    case hours
    
    // Đơn vị liên quan đến Apple Health
    case exerciseTime
    case steps
    case water
    
    static func custom() -> [GoalUnit] {
        [.count, .kcal, .lbs, .ml, .usoz, .mile, .km, .m, .secs, .min, .hours]
    }
    
    var description: String {
        switch self {
        case .secs: "giây"
        case .min, .exerciseTime: "phút"
        case .water: "ml"
        case .hours: "giờ"
        default: self.rawValue
        }
    }
}

extension GoalUnit {
    var useAppleHealth: Bool {
        switch self {
        case .steps: true
        case .exerciseTime: true
        case .water: true
        default: false
        }
    }
    
    var maximumAllowedValue: Double? {
        return switch self {
        case .steps: HKQuantityType(.stepCount).maximumAllowedDuration
        case .exerciseTime: HKObjectType.workoutType().maximumAllowedDuration
        case .water: HKQuantityType(.dietaryWater).maximumAllowedDuration
        default: nil
        }
    }
    
    var readType: HKSampleType? {
        switch self {
        case .steps: HKQuantityType(.stepCount)
        case .exerciseTime: HKQuantityType(.appleExerciseTime)
        case .water: HKQuantityType(.dietaryWater)
        default: nil
        }
    }
        
    var writeType: HKSampleType? {
        switch self {
        case .steps: HKQuantityType(.stepCount)
        case .exerciseTime: HKObjectType.workoutType()
        case .water: HKQuantityType(.dietaryWater)
        default: nil
        }
    }
    
    var permissionReadMessage: String {
        switch self {
        case .steps: "Bạn cần cấp quyền ứng dụng đọc số lượng bước"
        case .exerciseTime: "Bạn cần cấp quyền ứng dụng đọc thời gian tập thể dục"
        case .water: "Bạn cần cấp quyền ứng dụng đọc số lượng nước đã uống"
        default: ""
        }
    }
    
    var permissionWriteMessage: String {
        switch self {
        case .steps: "Bạn cần cấp quyền cho ứng dụng ghi số lượng bước"
        case .exerciseTime: "Bạn cần cấp quyền cho ứng dụng ghi thời gian workout"
        case .water: "Bạn cần cấp quyền ứng dụng ghi số lượng nước đã uống"
        default: ""
        }
    }
    
    // Quy đổi về đơn vị chuẩn (giây cho thời gian, kcal cho năng lượng, m cho quãng đường)
    func convertToBaseUnit(from value: Double) -> Double {
        switch self {
        case .min:
            return value * 60    // Quy đổi phút sang giây
        case .hours:
            return value * 3600       // Giây vẫn là giây
        default:
            return value
        }
    }
    
    // Quy đổi từ đơn vị chuẩn về đúng đơn vị
    func convertToUnit(from base: Double) -> Double {
        switch self {
        case .min:
            return base / 60    // Quy đổi phút sang giây
        case .hours:
            return base / 3600       // Giây vẫn là giây
        default:
            return base
        }
    }
}
