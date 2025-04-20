//
//  HealthManager.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 7/4/25.
//

import HealthKit

class HealthManager: NSObject {
    static let shared = HealthManager()
    private let healthStore = HKHealthStore()
    
    private var needToObserverStepCount: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "stepCountObserve")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "stepCountObserve")
        }
    }
    
    private var didStartStepObserver: Bool = false
    
    private override init() {
        super.init()
    }
    
    func startObserver() {
        if needToObserverStepCount && !didStartStepObserver {
            startObservingStepCount()
        }
    }
    
    // MARK: - Check Permission
    // Kiểm tra quyền ghi dữ liệu vào HealthKit
    func checkHealthKitWritePermission(type: HKSampleType, completion: ((Bool) -> Void)? = nil) {
        let status = healthStore.authorizationStatus(for: type)
        completion?(status == .sharingAuthorized)
    }
       
    // Kiểm tra quyền đọc dữ liệu từ HealthKit (có thể kết hợp để kiểm tra quyền đọc/ghi)
    func checkHealthKitReadPermission(type: HKSampleType, completion: ((Bool) -> Void)? = nil) {
        healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
            completion?(success)
        }
    }
    
    func checkHealthKitWritePermission(type: HKSampleType) async -> Bool {
        return await withUnsafeContinuation { continuation in
            let status = healthStore.authorizationStatus(for: type)
            continuation.resume(returning: status == .sharingAuthorized)
        }
        
    }
       
    // Kiểm tra quyền đọc dữ liệu từ HealthKit (có thể kết hợp để kiểm tra quyền đọc/ghi)
    func checkHealthKitReadPermission(type: HKSampleType) async -> Bool {
        return await withUnsafeContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
                continuation.resume(returning: success)
            }
        }
    }
    
    // MARK: - Request
    func requestAuthorization(for unit: GoalUnit, completion: @escaping @Sendable (Bool, Bool) -> Void) {
        healthStore.requestAuthorization(toShare: Set([unit.writeType!]), read: Set([unit.readType!])) { success, error in
            Task {
                let canRead = await self.checkHealthKitReadPermission(type: unit.readType!)
                let canWrite = await self.checkHealthKitWritePermission(type: unit.writeType!)
                
                DispatchQueue.main.async {
                    completion(canRead, canWrite)
                }
               
                if unit == .steps && !self.needToObserverStepCount {
                    self.needToObserverStepCount = true
                }
            }
        }
    }
    
    func canAccess(of unit: GoalUnit) async -> Bool {
        return await withUnsafeContinuation { continuation in
            self.checkHealthKitReadPermission(type: unit.readType!) { canRead in
                self.checkHealthKitWritePermission(type: unit.writeType!) { canWrite in
                    let isGrant = canRead && canWrite
                    continuation.resume(returning: isGrant)
                }
            }
        }
    }
    
    // MARK: - Water
    func fetchWaterInDate(endDate: Date) async -> Double {
        let dateEnd = endDate
        let dateStart = endDate.startOfDay
        
        // To get daily steps data
        let dayComponent = DateComponents(day: 1)
        
        let predicate = HKQuery.predicateForSamples(withStart: dateStart, end: dateEnd, options: .strictStartDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.dietaryWater), predicate: predicate)
        
        let descriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate, options: .cumulativeSum, anchorDate: dateStart, intervalComponents: dayComponent
        )
        
        let result = try? await descriptor.result(for: HKHealthStore())
        
        return await withUnsafeContinuation { continuation in
            result?.enumerateStatistics(from: dateStart, to: dateEnd) { statistics, stop in
                let ml = statistics.sumQuantity()?.doubleValue(for: .literUnit(with: .milli)) ?? 0
                continuation.resume(returning: ml)
            }
        }
    }
    
    // MARK: - Step count
    func startObservingStepCount() {
        didStartStepObserver = true
        Task {
            guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount), await checkHealthKitReadPermission(type: stepType) else {
                return
            }
            
            let query = HKObserverQuery(sampleType: stepType, predicate: nil) { _, completionHandler, error in
                if let error {
                    print("Observer query error: \(error.localizedDescription)")
                    return
                }
                
                for habit in HabitDAO.shared.getAll().filter({ $0.goalUnit == .steps }) {
                    HabitDAO.shared.setupStepRecordIfNeed(habit: habit)
                }
                
                completionHandler()
            }
            
            healthStore.execute(query)
            
            do {
                try await healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate)
                print("✅ Background delivery enabled")
            } catch {
                print("❌ Error enabling background delivery: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchStepCountDate(endDate: Date) async -> Double {
        let dateEnd = endDate
        let dateStart = endDate.startOfDay
        
        // To get daily steps data
        let dayComponent = DateComponents(day: 1)
        
        let predicate = HKQuery.predicateForSamples(withStart: dateStart, end: dateEnd, options: .strictStartDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: predicate)
        
        let descriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate, options: .cumulativeSum, anchorDate: dateStart, intervalComponents: dayComponent
        )
        
        let result = try? await descriptor.result(for: HKHealthStore())
        
        return await withUnsafeContinuation { continuation in
            result?.enumerateStatistics(from: dateStart, to: dateEnd) { statistics, stop in
                let steps = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: steps)
            }
        }
    }
    
    func fetchHourlyStepCountData(endDate: Date, completion: @escaping ([Date: Double]?, Error?) -> Void) {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, NSError(domain: "YourAppDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Step count type not available"]))
            return
        }
        
        let startDate = endDate.startOfDay
        let interval = DateComponents(hour: 1) // Khoảng thời gian là 1 giờ
        
        let query = HKStatisticsCollectionQuery(quantityType: stepCountType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: startDate, // Điểm bắt đầu cho việc phân chia khoảng thời gian
                                                intervalComponents: interval)
        
        query.initialResultsHandler = {_, statisticsCollection, error in
            if let error = error {
                print("Lỗi khi truy vấn dữ liệu bước chân theo giờ: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            var hourlyStepCounts: [Date: Double] = [:]
            
            // Duyệt qua tất cả các thống kê trong khoảng thời gian đã chỉ định
            statisticsCollection?.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
                if let quantity = statistics.sumQuantity() {
                    let steps = quantity.doubleValue(for: HKUnit.count())
                    let endDate = statistics.endDate
                    hourlyStepCounts[endDate] = steps
                }
            }
            
            completion(hourlyStepCounts, nil)
        }
        
        healthStore.execute(query)
    }
    
    func addSteps(steps: Double, date: Date, completion: ((Bool, Error?) -> Void)? = nil) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let quantity = HKQuantity(unit: HKUnit.count(), doubleValue: steps)
        let sample = HKQuantitySample(type: stepType, quantity: quantity, start: date, end: date)
        
        healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion?(success, error)
            }
        }
    }
    
    // MARK: - Exercise Time
    func fetchExerciseTime(endDate: Date) async -> Double {
        let startDate = endDate.startOfDay
        
        return await withUnsafeContinuation { continuation in
            let type = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }

                let totalSecond = sum.doubleValue(for: .second())
                continuation.resume(returning: totalSecond)
            }

            healthStore.execute(query)
        }
    }
    
    func saveWorkout(byAdding component: Calendar.Component, time: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
        // Lấy ngày, giờ, phút, giây từ thời điểm hiện tại
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: date)
        let currentMonth = calendar.component(.month, from: date)
        let currentDay = calendar.component(.day, from: date)

        // Lấy giờ, phút, giây từ date bạn có
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())
        let second = calendar.component(.second, from: Date())

        // Tạo Date mới với ngày hiện tại và giữ nguyên giờ, phút, giây của date bạn có
        let endDate = calendar.date(bySettingHour: hour, minute: minute, second: second, of: calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: currentDay))!)!
        
        let start = calendar.date(byAdding: component, value: Int(-abs(time)), to: endDate)!

        let workout = HKWorkout(activityType: .other,
                                start: start,
                                end: endDate)

        healthStore.save(workout) { success, error in
            completion(success, error)
            
            if success {
                print("Workout đã được lưu vào HealthKit")
            } else {
                print("Lỗi khi lưu workout: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func saveData(for unit: GoalUnit, value: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
        switch unit {
        case .steps:
            addSteps(steps: value, date: date, completion: completion)
        case .exerciseTime:
            saveWorkout(byAdding: .minute, time: value, date: date, completion: completion)
        case .water:
            addWater(ml: value, date: date, completion: completion)
        default: break
        }
    }
    
    func addWater(ml: Double, date: Date, completion: ((Bool, Error?) -> Void)? = nil) {
        let type = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: ml)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        
        healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion?(success, error)
                print(error)
            }
        }
    }
}
