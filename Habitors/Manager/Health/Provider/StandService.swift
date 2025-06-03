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
    private var didObserver: Bool = false

    var didRequestPermission: Bool {
        get {
            UserDefaults.standard.bool(forKey: "StandService")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "StandService")
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
    
    func startObserver() async {
        guard !didObserver && didRequestPermission, let type = HKObjectType.quantityType(forIdentifier: .appleStandTime), await checkReadPermission() else {
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
            print("✅ Theo dõi sự thay đổi về thời gian đứng thành công!")
        } catch {
            print("❌ Error enabling background delivery: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Request Permission
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .appleStandTime) else {
            completion(false)
            return
        }
        
        self.didRequestPermission = true
        healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
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
        guard let type = HKObjectType.quantityType(forIdentifier: .appleStandTime) else {
            completion?(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
            completion?(success)
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

