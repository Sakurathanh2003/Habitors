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
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(false)
            return
        }
        
        self.didRequestPermission = true
        healthStore.requestAuthorization(toShare: nil , read: Set([type])) { success, error in
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
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion?(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: Set([type])) { success, error in
            completion?(success)
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
