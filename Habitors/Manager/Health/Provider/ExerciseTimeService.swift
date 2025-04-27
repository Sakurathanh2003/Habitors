//
//  ExerciseTimeService.swift
//  Habitors
//
//  Created by Thanh Vu on 22/4/25.
//

import Foundation
import HealthKit
 
class ExerciseTimeService: HealthService {
    private let healthStore = HKHealthStore()
    private var didObserver: Bool = false
    
    var didRequestPermission: Bool {
        get {
            UserDefaults.standard.bool(forKey: "ExerciseTimeService")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ExerciseTimeService")
            if newValue {
                Task {
                    await self.startObserver()
                }
            }
        }
    }
    
    func fetchData(for date: Date) async -> Double {
        let startDate = date.startOfDay
        
        return await withUnsafeContinuation { continuation in
            let type = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: date, options: .strictStartDate)

            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }

                let totalSecond = sum.doubleValue(for: .minute())
                continuation.resume(returning: totalSecond)
            }

            healthStore.execute(query)
        }
    }
    
    func saveData(_ data: Double, in date: Date, completion: ((Bool, (any Error)?) -> Void)?) {
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
        let endDate = calendar.date(bySettingHour: hour,
                                    minute: minute,
                                    second: second,
                                    of: calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: currentDay))!)!
        
        let start = calendar.date(byAdding: .minute, value: Int(-abs(data)), to: endDate)!

        let workout = HKWorkout(activityType: .other,
                                start: start,
                                end: endDate,
                                duration: TimeInterval(data * 60.0),
                                totalEnergyBurned: nil, totalDistance: nil, metadata: nil)
        
        healthStore.save(workout) { success, error in
            completion?(success, error)
            
            if success {
                print("Workout đã được lưu vào HealthKit")
            } else {
                print("Lỗi khi lưu workout: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Obersever
    func startObserver() async {
        guard !didObserver && didRequestPermission, let stepType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime), await checkReadPermission() else {
            return
        }
        
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { _, completionHandler, error in
            if let error {
                print("Observer query error: \(error.localizedDescription)")
                return
            }
            
            for habit in HabitDAO.shared.getAll().filter({ $0.goalUnit == .exerciseTime }) {
                HabitDAO.shared.setupRecordIfNeed(habit: habit)
            }
            
            completionHandler()
        }
        
        healthStore.execute(query)
        
        do {
            try await healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate)
            self.didObserver = true
            print("✅ Theo dõi sự thay đổi về thời gian tập luyện thành công!")
        } catch {
            print("❌ Error enabling background delivery: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Request Permission
    func requestAuthorization(completion: @escaping (Bool, Bool) -> Void) {
        guard let readType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            completion(false, false)
            return
        }
        
        let writeType = HKObjectType.workoutType()
        self.didRequestPermission = true
        healthStore.requestAuthorization(toShare: Set([writeType]), read: Set([readType])) { success, error in
            Task {
                let canRead = await self.checkReadPermission()
                let canWrite = await self.checkWritePermission()
                
                DispatchQueue.main.async {
                    completion(canRead, canWrite)
                }
            }
        }
    }
    
    // MARK: - Check Permission
    func checkWritePermission(completion: ((Bool) -> Void)?) {
        let type = HKObjectType.workoutType()
        let status = healthStore.authorizationStatus(for: type)
        completion?(status == .sharingAuthorized)
    }
    
    func checkReadPermission(completion: ((Bool) -> Void)?) {
        guard let type = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) else {
            completion?(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
            completion?(success)
        }
    }
    
    func checkWritePermission() async -> Bool {
        let type = HKObjectType.workoutType()
        return await withUnsafeContinuation { continuation in
            let status = healthStore.authorizationStatus(for: type)
            continuation.resume(returning: status == .sharingAuthorized)
        }
    }
    
    func checkReadPermission() async -> Bool {
        guard let type = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) else {
            return false
        }
        
        return await withUnsafeContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
                continuation.resume(returning: success)
            }
        }
    }
}
