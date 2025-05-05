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
        center.requestAuthorization(options: [.alert, .sound, .badge, .provisional, .providesAppNotificationSettings]) { granted, error in
            if granted {
                print("Permission granted!")
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
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
        
        if let nearestReminderDay = item.nearestReminderDay {
            let notificationContent = notificationContent(for: item)
            
            var dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                                from: nearestReminderDay)
            var requests = [UNNotificationRequest]()
            for index in 0..<15 {
                let id = UUID().uuidString
                
                dateComponent.second = index * 2
                notificationContent.subtitle = "\(index)"
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)

                let request = UNNotificationRequest(identifier: id,
                                                    content: notificationContent,
                                                    trigger: trigger)
                
                notiID[item.id]?.append(id)
                requests.append(request)
            }
            
            for request in requests {
                UNUserNotificationCenter.current().add(request) { error in
                    if let error {
                        print("Lỗi khi thêm thông báo 1: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
        
    private func notificationContent(for item: Habit) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.interruptionLevel = .active
        content.title = "Bạn có nhắc nhở!"
        
        let body = "habit: \(item.name) "
        content.body = body
        
        content.sound = .criticalSoundNamed(UNNotificationSoundName("Orkney.mp3"),
                                            withAudioVolume: 1) // Thay "ringtone.mp3" bằng tên tệp của bạn
    
        content.categoryIdentifier = "myNotificationCategory"
        return content
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension HabitScheduler: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

// MARK: - Habit Extension
extension Habit {
    var nearestReminderDay: Date? {
        var reminder = [Time]()
        switch frequency.type {
        case .daily:
            reminder = frequency.daily.reminder
            if frequency.daily.reminder.isEmpty || frequency.daily.selectedDays.isEmpty {
                return nil
            }
        case .weekly:
            reminder = frequency.weekly.reminder
            if frequency.weekly.reminder.isEmpty {
                return nil
            }
        case .monthly:
            reminder = frequency.monthly.reminder
            if frequency.monthly.reminder.isEmpty {
                return nil
            }
        }
        
        reminder = reminder.sorted(by: { $0.hour <= $1.hour && $0.minutes <= $1.minutes })
        var day = Date()
        
        while true {
            if day.isDateValid(self) {
                break
            }
            
            day = day.tomorrow
        }
        
        if let item = reminder.first {
            var component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: day)
            component.minute = item.minutes
            component.hour = item.hour
            
            if let finalDay = Calendar.current.date(from: component) {
                day = finalDay
            }
        }
        
        return day
    }
}
