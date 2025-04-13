//
//  AppDelegate.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var coodinator: AppCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configRealm()
        configAppCoordinator()
        HabitScheduler.requestNotificationPermission()
        HealthManager.shared.startObserver()
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
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        HealthManager.shared.startObserver()
    }
}

