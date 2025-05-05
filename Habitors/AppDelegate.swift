//
//  AppDelegate.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import UIKit
import BackgroundTasks
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var coodinator: AppCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configRealm()
        configAppCoordinator()
        configAppleHealthService()
        HabitScheduler.shared.requestNotificationPermission()
        registerBackgroundTask()
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
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundTask()
    }
    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.thanhvu.habitors.fetchData", using: nil) { task in
            self.handleBackgroundFetch(task: task)
        }
    }

    func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: "com.thanhvu.habitors.fetchData")
        request.requiresExternalPower = false
        request.requiresNetworkConnectivity = false
        request.earliestBeginDate = Date()
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to submit background task: \(error)")
        }
    }

    func handleBackgroundFetch(task: BGTask) {
        let content = UNMutableNotificationContent()
        content.interruptionLevel = .active
        content.title = "Bạn có nhắc nhở!"
        
        let body = "Test"
        content.body = body
        
        content.sound = .criticalSoundNamed(UNNotificationSoundName("Orkney.mp3"),
                                            withAudioVolume: 1) // Thay "ringtone.mp3" bằng tên tệp của bạn
    
        content.categoryIdentifier = "myNotificationCategory"
        

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: nil)
        
        // Thêm vào hệ thống
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Lỗi khi thêm thông báo 1: \(error.localizedDescription)")
            }
        }
        task.setTaskCompleted(success: true)
    }
}

