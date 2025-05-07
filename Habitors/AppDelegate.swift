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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var coodinator: AppCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configRealm()
        configAppCoordinator()
        configAppleHealthService()
        HabitScheduler.shared.requestNotificationPermission()
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
        Task {
            await WaterService().startObserver()
            await StepCountService().startObserver()
            await ExerciseTimeService().startObserver()
            await StandService().startObserver()
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
        completionHandler([.alert, .banner, .list])
    }
}

