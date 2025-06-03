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
    case standHour
    
    static func custom() -> [GoalUnit] {
        [.count, .kcal, .lbs, .ml, .usoz, .mile, .km, .m, .secs, .min, .hours]
    }
    
    var description: String {
        switch self {
        case .secs: User.isVietnamese ? "giây" : "seconds"
        case .min, .exerciseTime, .standHour: User.isVietnamese ? "phút" : "minutes"
        case .water: "ml"
        case .hours: User.isVietnamese ? "giờ" : "hours"
        case .count: User.isVietnamese ? "lần" : "count"
        case .kcal: User.isVietnamese ? "kcal" : "kcal"
        case .lbs: self.rawValue
        case .ml: self.rawValue
        case .usoz: self.rawValue
        case .liter: self.rawValue
        case .mile: self.rawValue
        case .km: self.rawValue
        case .m: self.rawValue
        case .steps: User.isVietnamese ? "bước" : "steps"
        }
    }
}

extension GoalUnit {
    var useAppleHealth: Bool {
        switch self {
        case .steps, .exerciseTime, .water, .standHour: true
        default: false
        }
    }
    
    var maximumAllowedValue: Double? {
        return switch self {
        case .steps: HKQuantityType(.stepCount).maximumAllowedDuration
        case .exerciseTime: HKObjectType.workoutType().maximumAllowedDuration
        case .water: HKQuantityType(.dietaryWater).maximumAllowedDuration
        case .standHour: HKQuantityType(.appleStandTime).maximumAllowedDuration
        default: nil
        }
    }
    
    var readType: HKSampleType? {
        switch self {
        case .steps: HKQuantityType(.stepCount)
        case .exerciseTime: HKQuantityType(.appleExerciseTime)
        case .water: HKQuantityType(.dietaryWater)
        case .standHour: HKQuantityType(.appleStandTime)
        default: nil
        }
    }
        
    var writeType: HKSampleType? {
        switch self {
        case .steps: HKQuantityType(.stepCount)
        case .water: HKQuantityType(.dietaryWater)
        default: nil
        }
    }
    
    var permissionReadMessage: String {
        switch self {
        case .steps: User.isVietnamese ?  "Bạn cần cấp quyền ứng dụng đọc số lượng bước" : "You need to grant the app permission to read the number of steps"
        case .exerciseTime: User.isVietnamese ? "Bạn cần cấp quyền ứng dụng đọc thời gian tập thể dục" : "You need to grant the app permission to read exercise time"
        case .water: User.isVietnamese ? "Bạn cần cấp quyền ứng dụng đọc số lượng nước đã uống" : "You need to grant the app permission to read the amount of water you have drunk."
        case .standHour: User.isVietnamese ? "Bạn cần cấp quyền ứng dụng đọc số giờ đứng" : "You need to grant the application permission to read standing hours"
        default: ""
        }
    }
    
    var permissionWriteMessage: String {
        switch self {
        case .steps: User.isVietnamese ? "Bạn cần cấp quyền cho ứng dụng ghi số lượng bước" : "You need to grant permission for the app to record steps"
        case .exerciseTime: User.isVietnamese ? "Bạn cần cấp quyền cho ứng dụng ghi thời gian workout" : "You need to grant permission for the app to record workout time"
        case .water: User.isVietnamese ? "Bạn cần cấp quyền ứng dụng ghi số lượng nước đã uống" : "You need to grant the app permission to record the amount of water you drink"
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
    
    var canSetData: Bool {
        return false
    }
    
    var maxValue: Double? {
        switch self {
        case .standHour: 1440
        default: nil
        }
    }
}

// MARK: - Apple Health
extension GoalUnit {
    var healthService: HealthService? {
        switch self {
        case .exerciseTime: ExerciseTimeService()
        case .water: WaterService()
        case .steps: StepCountService()
        case .standHour: StandService()
        default: nil
        }
    }
}
