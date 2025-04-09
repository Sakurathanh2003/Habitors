//
//  HabitScheduler.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 1/4/25.
//

import Foundation
import UserNotifications
import UIKit

class HabitScheduler {
    static var notiID: [String: [String]] {
        get {
            UserDefaults.standard.value(forKey: "notiID") as? [String: [String]] ?? [:]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "notiID")
        }
    }
    
    static func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.criticalAlert, .alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted!")
            } else {
                print("Permission denied!")
            }
        }
    }
    
    // MARK: - Delete schedule
    static func deleteSchedule(for item: Habit) {
        if let ids = notiID[item.id] {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
    
    static func startSchedule(for item: Habit) {
        self.deleteSchedule(for: item)
        
        let frequency = item.frequency
        let repeatType = frequency.type
        
        if let nearestReminderDay = item.nearestReminderDay {
            let content = UNMutableNotificationContent()
            content.title = "Thông báo 1"
            content.body = "Đây là thông báo đầu tiên."
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "alarm"
            
            let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: nearestReminderDay)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
            let request = UNNotificationRequest(identifier: "Notification1", content: content, trigger: trigger)
            
            // Thêm vào hệ thống
            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    print("Lỗi khi thêm thông báo 1: \(error.localizedDescription)")
                }
            }
        }
    }
        
    private static func notificationContent(for item: Habit) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.interruptionLevel = .critical
        content.title = "Mở ứng dụng ngay!"
        
        let body = "habit: \(item.name) "
        content.body = body
        
        let sound = UNNotificationSound(named: UNNotificationSoundName("ringtone.mp3"))
        content.sound = sound // Thay "ringtone.mp3" bằng tên tệp của bạn
        return content
    }
}

// MARK: - Habit Extension
extension Habit {
    var nearestReminderDay: Date? {
        switch frequency.type {
        case .daily:
            if frequency.daily.reminder.isEmpty || frequency.daily.selectedDays.isEmpty {
                return nil
            } else {
                let daily = frequency.daily
                let currentDay = Date()
                let calendar = Calendar.current
                let currentWeekday = calendar.component(.weekday, from: currentDay) // Lấy ngày trong tuần hiện tại (1 = Chủ nhật, 7 = Thứ 7)
                
                let sortedReminder = daily.reminder.sorted { $0.hour <= $1.hour && $0.minutes <= $1.minutes }
                let sortedSelectedDays = daily.selectedDays.map({ $0 == 8 ? 1 : $0 }).sorted { $0 <= $1 }
                
                // Lọc ra các ngày trong tuần mà người dùng đã chọn và lớn hơn hoặc bằng ngày hôm nay
                var validDays = sortedSelectedDays.filter { $0 >= currentWeekday }
                
                if validDays.isEmpty {
                    validDays.append(sortedSelectedDays.first!)
                }
                
                var valueDay: Date? = nil
                
                // Duyệt qua tất cả các nhắc nhở trong ngày
                for selectedDay in daily.selectedDays {
                    guard let nextValidDay = currentDay.nextWeekday(selectedDay) else {
                        continue
                    }
                    
                    for reminder in sortedReminder {
                        let reminderHour = reminder.hour
                        let reminderMinute = reminder.minutes
                        
                        // Tính toán thời gian nhắc nhở cho ngày hợp lệ tiếp theo
                        var components = calendar.dateComponents([.year, .month, .day], from: nextValidDay)
                        components.hour = reminderHour
                        components.minute = reminderMinute
                        
                        guard let reminderDate = calendar.date(from: components) else {
                            continue
                        }
                        
                        // Nếu thời gian nhắc nhở đã qua, tính toán lại vào tuần sau
                        var validReminderDate = reminderDate
                        if validReminderDate < currentDay {
                            validReminderDate = calendar.date(byAdding: .weekOfMonth, value: 1, to: validReminderDate)!
                        }
                        
                        // Cập nhật valueDay nếu validReminderDate sớm hơn
                        valueDay = valueDay == nil ? validReminderDate : min(valueDay!, validReminderDate)
                    }
                }
                
                return valueDay
            }
        case .weekly:
            if frequency.daily.reminder.isEmpty {
                return nil
            }
        case .monthly:
            if frequency.daily.reminder.isEmpty {
                return nil
            }
        }
        
        return nil
    }
}
