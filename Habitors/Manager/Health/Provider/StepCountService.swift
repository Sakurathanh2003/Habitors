//
//  StepManager.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 20/4/25.
//

import Foundation
import HealthKit

class StepCountService: HealthService {
    private let healthStore = HKHealthStore()
    private var didObserver: Bool = false

    var didRequestPermission: Bool {
        get {
            UserDefaults.standard.bool(forKey: "StepCountService")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "StepCountService")
            if newValue {
                Task {
                    await self.startObserver()
                }
            }
        }
    }
    
    // MARK: - Fetch
    func fetchData(for date: Date) async -> Double {
        let dateEnd = date
        let dateStart = date.startOfDay
        
        let dayComponent = DateComponents(day: 1)
        
        let predicate = HKQuery.predicateForSamples(withStart: dateStart, end: dateEnd, options: .strictStartDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: predicate)
        
        let descriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate, options: .cumulativeSum, anchorDate: dateStart, intervalComponents: dayComponent
        )
        
        let result = try? await descriptor.result(for: healthStore)

        return await withUnsafeContinuation { continuation in
            result?.enumerateStatistics(from: dateStart, to: dateEnd) { statistics, stop in
                let steps = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: steps)
            }
        }
    }
    
    // MARK: - Save
    func saveData(_ data: Double, in date: Date, completion: ((Bool, (any Error)?) -> Void)?) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let quantity = HKQuantity(unit: HKUnit.count(), doubleValue: data)
        let sample = HKQuantitySample(type: stepType, quantity: quantity, start: date, end: date)
        
        healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion?(success, error)
            }
        }
    }
    
    // MARK: - Observer
    func startObserver() async {
        guard !didObserver && didRequestPermission, let stepType = HKObjectType.quantityType(forIdentifier: .stepCount), await checkReadPermission() else {
            return
        }
        
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { _, completionHandler, error in
            if let error {
                print("Observer query error: \(error.localizedDescription)")
                return
            }
            
            for habit in HabitDAO.shared.getAll().filter({ $0.goalUnit == .steps }) {
                HabitDAO.shared.setupRecordIfNeed(habit: habit)
            }
            
            completionHandler()
        }
        
        healthStore.execute(query)
        
        do {
            try await healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate)
            print("✅ Theo dõi sự thay đổi về bước đi thành công!")
            
        } catch {
            print("❌ Error enabling background delivery: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Request Permission
    func requestAuthorization(completion: @escaping (Bool, Bool) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(false, false)
            return
        }
        
        self.didRequestPermission = true
        healthStore.requestAuthorization(toShare: Set([type]), read: Set([type])) { success, error in
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
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion?(false)
            return
        }
        
        let status = healthStore.authorizationStatus(for: type)
        completion?(status == .sharingAuthorized)
    }
    
    func checkReadPermission(completion: ((Bool) -> Void)?) {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion?(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
            completion?(success)
        }
    }
    
    func checkWritePermission() async -> Bool {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return false
        }
        
        return await withUnsafeContinuation { continuation in
            let status = healthStore.authorizationStatus(for: type)
            continuation.resume(returning: status == .sharingAuthorized)
        }
    }
    
    func checkReadPermission() async -> Bool {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return false
        }
        
        return await withUnsafeContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
                continuation.resume(returning: success)
            }
        }
    }
}
