//
//  StandService.swift
//  Habitors
//
//  Created by Thanh Vu on 23/4/25.
//

import Foundation
import HealthKit

class StandService: HealthService {
    private let healthStore = HKHealthStore()
    
    func fetchData(for date: Date) async -> Double {
        let dateEnd = date
        let dateStart = date.startOfDay
        
        // To get daily steps data
        let dayComponent = DateComponents(day: 1)
        
        let predicate = HKQuery.predicateForSamples(withStart: dateStart, end: dateEnd, options: .strictStartDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.appleStandTime), predicate: predicate)
        
        let descriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate, options: .cumulativeSum, anchorDate: dateStart, intervalComponents: dayComponent
        )
        
        let result = try? await descriptor.result(for: HKHealthStore())
        
        return await withUnsafeContinuation { continuation in
            result?.enumerateStatistics(from: dateStart, to: dateEnd) { statistics, stop in
                let value = statistics.sumQuantity()?.doubleValue(for: .minute()) ?? 0
                continuation.resume(returning: value)
            }
        }
    }
    
    func saveData(_ data: Double, in date: Date, completion: ((Bool, (any Error)?) -> Void)?) {
        completion?(false, NSError(domain: "Stand", code: 404, userInfo: [NSLocalizedDescriptionKey: "Không hỗ trợ thêm giá trị"]))
    }
    
    func startObserver() async {
        guard let type = HKObjectType.quantityType(forIdentifier: .appleStandTime), await checkReadPermission() else {
            return
        }
        
        let query = HKObserverQuery(sampleType: type, predicate: nil) { _, completionHandler, error in
            if let error {
                print("Observer query error: \(error.localizedDescription)")
                return
            }
            
            for habit in HabitDAO.shared.getAll().filter({ $0.goalUnit == .standHour }) {
                HabitDAO.shared.setupRecordIfNeed(habit: habit)
            }
            
            completionHandler()
        }
        
        healthStore.execute(query)
        
        do {
            try await healthStore.enableBackgroundDelivery(for: type, frequency: .immediate)
            print("✅ Background delivery enabled")
        } catch {
            print("❌ Error enabling background delivery: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Request Permission
    func requestAuthorization(completion: @escaping (Bool, Bool) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .appleStandTime) else {
            completion(false, false)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
            Task {
                let canRead = await self.checkReadPermission()
                
                DispatchQueue.main.async {
                    completion(canRead, canRead)
                }
            }
        }
    }
    
    // MARK: - Check Permission
    func checkWritePermission(completion: ((Bool) -> Void)?) {
        guard let type = HKObjectType.quantityType(forIdentifier: .appleStandTime) else {
            completion?(false)
            return
        }
        
        let status = healthStore.authorizationStatus(for: type)
        completion?(status == .sharingAuthorized)
    }
    
    func checkReadPermission(completion: ((Bool) -> Void)?) {
        guard let type = HKObjectType.quantityType(forIdentifier: .appleStandTime) else {
            completion?(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
            completion?(success)
        }
    }
    
    func checkWritePermission() async -> Bool {
        guard let type = HKObjectType.quantityType(forIdentifier: .appleStandTime) else {
            return false
        }
        
        return await withUnsafeContinuation { continuation in
            let status = healthStore.authorizationStatus(for: type)
            continuation.resume(returning: status == .sharingAuthorized)
        }
    }
    
    func checkReadPermission() async -> Bool {
        guard let type = HKObjectType.quantityType(forIdentifier: .appleStandTime) else {
            return false
        }
        
        return await withUnsafeContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
                continuation.resume(returning: success)
            }
        }
    }
}

