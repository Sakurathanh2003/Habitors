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
    
    private override init() {
        super.init()
    }
    
    func start() {
        if needToObserverStepCount {
            startObservingStepCount()
        }
    }
    
    // MARK: - Request
    func requestAuthorization(for type: HKQuantityType, completion: @escaping @Sendable (Bool, String?) -> Void) {
        let share: Set<HKSampleType> = type.canWrite ? [type] : []
        healthStore.requestAuthorization(toShare: share, read: [type]) { success, error in
            Task {
                let isGrant = await self.canAccess(of: type)
                completion(isGrant, type.requestMessage)
                
                if type.identifier == HKQuantityTypeIdentifier.stepCount.rawValue && !self.needToObserverStepCount {
                    self.needToObserverStepCount = true
                    self.startObservingStepCount()
                }
            }
        }
    }
    
    func canAccess(of type: HKQuantityType) async -> Bool {
        let share: Set<HKSampleType> = type.canWrite ? [type] : []
        let status = try? await healthStore.statusForAuthorizationRequest(toShare: share, read: [type])
        return status == .unnecessary
    }
    
    // MARK: - Step count
    func startObservingStepCount() {
        Task {
            guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount), await canAccess(of: stepType) else {
                return
            }
            
            let query = HKObserverQuery(sampleType: stepType, predicate: nil) { _, completionHandler, error in
                if let error {
                    print("Observer query error: \(error.localizedDescription)")
                    return
                }
                
                for habit in HabitDAO.shared.getAll() {
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
    func fetchExerciseTime(startDate: Date, endDate: Date, completion: @escaping (Double) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }

            let totalMinutes = sum.doubleValue(for: .second())
            completion(totalMinutes)
        }

        healthStore.execute(query)
    }
}

// MARK: - Extension
extension HKQuantityType {
    var canWrite: Bool {
        switch self.identifier {
        case HKQuantityTypeIdentifier.appleExerciseTime.rawValue:
            false
        case HKQuantityTypeIdentifier.appleStandTime.rawValue:
            false
        default:
            true
        }
    }
    
    var requestMessage: String {
        switch self.identifier {
        case HKQuantityTypeIdentifier.appleExerciseTime.rawValue:
            "Bạn cần cấp quyền đọc thời gian tập"
        case HKQuantityTypeIdentifier.appleStandTime.rawValue:
            "Bạn cần cấp quyền đọc thời gian đứng"
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            "Bạn cần cấp quyền đọc và ghi số bước"
        default:
            "Bạn cần cấp quyền vừa yêu cầu"
        }
    }
}
