//
//  AppDelegate.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import UIKit
import BackgroundTasks
import UserNotifications
import AppTrackingTransparency
import HealthKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var coodinator: AppCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configRealm()
        configAppleHealthService()
        configAppCoordinator()
        return true
    }
    
    private func configRealm() {
        RealmManager.configRealm()
    }
    
    private func configAppCoordinator() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.coodinator = AppCoordinator(window: self.window!)
        self.coodinator.start()
    }
    
    private func configAppleHealthService() {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater),
              let exerciseTimeType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime),
              let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
                let standType = HKObjectType.quantityType(forIdentifier: .appleStandTime)else {
            return
        }
        
        let healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: nil, read: Set([waterType, exerciseTimeType, stepType, standType])) { success, error in
            HabitScheduler.shared.requestNotificationPermission()

            Task {
                await WaterService().startObserver()
                await StepCountService().startObserver()
                await ExerciseTimeService().startObserver()
                await StandService().startObserver()
            }
        }
    }
    
    let notificationCenter = UNUserNotificationCenter.current()
    var mainRequests = [UNNotificationRequest]()
    
    // MARK: - Life Cycle
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .badge, .sound])
    }
}

