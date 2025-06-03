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
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let readType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) else {
            completion(false)
            return
        }
        
        self.didRequestPermission = true
        healthStore.requestAuthorization(toShare: nil, read: Set([readType])) { success, error in
            Task {
                let canRead = await self.checkReadPermission()
                
                DispatchQueue.main.async {
                    completion(canRead)
                }
            }
        }
    }
    
    // MARK: - Check Permission
    func checkReadPermission(completion: ((Bool) -> Void)?) {
        guard let type = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) else {
            completion?(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
            completion?(success)
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
