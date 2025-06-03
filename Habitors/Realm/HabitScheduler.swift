//
//  HabitScheduler.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 1/4/25.
//

import Foundation
import UserNotifications
import UIKit

class HabitScheduler: NSObject {
    static let shared = HabitScheduler()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    private var notiID: [String: [String]] {
        get {
            UserDefaults.standard.value(forKey: "notiID") as? [String: [String]] ?? [:]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "notiID")
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
            if granted {
                print("Permission granted!")
            } else {
                print("Permission denied!")
            }
        }
    }
    
    // MARK: - Delete schedule
    func deleteSchedule(for item: Habit) {
        if let ids = notiID[item.id] {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
    
    func startSchedule(for item: Habit) {
        self.deleteSchedule(for: item)
        
        switch item.frequency.type {
        case .daily:
            for time in item.reminder {
                schedule(for: item, weekday: nil, time: time)
            }
        case .weekly:
            if item.frequency.weekly.selectedDays.count == 7 {
                for time in item.reminder {
                    schedule(for: item, weekday: nil, time: time)
                }
            } else {
                for weekday in item.frequency.weekly.selectedDays {
                    for time in item.reminder {
                        schedule(for: item, weekday: weekday, time: time)
                    }
                }
            }
        case .monthly:
            switch item.frequency.monthly.type {
            case .beginning:
                for day in 0...10 {
                    for time in item.reminder {
                        schedule(for: item, day: day, time: time)
                    }
                }
            case .middle:
                for day in 11...20 {
                    for time in item.reminder {
                        schedule(for: item, day: day, time: time)
                    }
                }
            case .end:
                for day in 21...31 {
                    for time in item.reminder {
                        schedule(for: item, day: day, time: time)
                    }
                }
            }
        }
    }
    
    private func schedule(for item: Habit, weekday: Int? = nil, day: Int? = nil, time: Time) {
        let id = UUID().uuidString
        let notificationContent = notificationContent(for: item)
        var dateComponent = DateComponents()
        
        dateComponent.hour = time.hour
        dateComponent.minute = time.minutes
        dateComponent.weekday = weekday
        dateComponent.day = day
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Lỗi khi thêm thông báo 1: \(error.localizedDescription)")
            } else {
                if self.notiID[item.id] == nil {
                    self.notiID[item.id] = [id]
                } else {
                    self.notiID[item.id]?.append(id)
                }
            }
        }
    }
        
    private func notificationContent(for item: Habit) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.interruptionLevel = .critical
        content.title = "Bạn có nhắc nhở!"
        
        let body = "habit: \(item.name) "
        content.body = body
        
        content.sound = .criticalSoundNamed(UNNotificationSoundName("orkney.mp3"),
                                            withAudioVolume: 1) // Thay "ringtone.mp3" bằng tên tệp của bạn
    
        return content
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension HabitScheduler: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound, .list, .banner])
    }
}
