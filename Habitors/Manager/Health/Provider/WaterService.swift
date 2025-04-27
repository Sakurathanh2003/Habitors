//
//  WaterService.swift
//  Habitors
//
//  Created by Thanh Vu on 22/4/25.
//

import Foundation
import HealthKit

class WaterService: HealthService {
    private let healthStore = HKHealthStore()
    private var didObserver: Bool = false

    var didRequestPermission: Bool {
        get {
            UserDefaults.standard.bool(forKey: "WaterService")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "WaterService")
            if newValue {
                Task {
                    await self.startObserver()
                }
            }
        }
    }

    func fetchData(for date: Date) async -> Double {
        let dateEnd = date
        let dateStart = date.startOfDay
        
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
    
    func saveData(_ data: Double, in date: Date, completion: ((Bool, (any Error)?) -> Void)?) {
        let type = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: data)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        
        healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion?(success, error)
            }
        }
    }
    
    func startObserver() async {
        guard !didObserver && didRequestPermission, let stepType = HKObjectType.quantityType(forIdentifier: .dietaryWater), await checkReadPermission() else {
            return
        }
        
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { _, completionHandler, error in
            if let error {
                print("Observer query error: \(error.localizedDescription)")
                return
            }
            
            for habit in HabitDAO.shared.getAll().filter({ $0.goalUnit == .water }) {
                HabitDAO.shared.setupRecordIfNeed(habit: habit)
            }
            
            completionHandler()
        }
        
        healthStore.execute(query)
        
        do {
            try await healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate)
            print("✅ Theo dõi sự thay đổi về nước uống thành công!")
        } catch {
            print("❌ Error enabling background delivery: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Request Permission
    func requestAuthorization(completion: @escaping (Bool, Bool) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
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
        guard let type = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            completion?(false)
            return
        }
        
        let status = healthStore.authorizationStatus(for: type)
        completion?(status == .sharingAuthorized)
    }
    
    func checkReadPermission(completion: ((Bool) -> Void)?) {
        guard let type = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            completion?(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
            completion?(success)
        }
    }
    
    func checkWritePermission() async -> Bool {
        guard let type = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            return false
        }
        
        return await withUnsafeContinuation { continuation in
            let status = healthStore.authorizationStatus(for: type)
            continuation.resume(returning: status == .sharingAuthorized)
        }
    }
    
    func checkReadPermission() async -> Bool {
        guard let type = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            return false
        }
        
        return await withUnsafeContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
                continuation.resume(returning: success)
            }
        }
    }
}

