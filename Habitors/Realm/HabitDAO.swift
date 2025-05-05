//
//  HabitDAO.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 20/3/25.
//

import UIKit
import RealmSwift
import Realm

extension Notification.Name {
    static let addHabitItem = Notification.Name("deleteHabitItem")
    static let updateHabitItem = Notification.Name("updateHabitItem")
    static let deleteHabitItem = Notification.Name("deleteHabitItem")
}

final class HabitDAO: RealmDao {
    static let shared = HabitDAO()
    
    // MARK: - Add habit
    func addObject(item: Habit) {
        let object = item.rlmObject()
        
        do {
            try self.addObjectAndUpdate(object)
            print("✅ Đã thêm 1 habit: \(item.name)")
            setupRecordIfNeed(habit: item)
            NotificationCenter.default.post(name: .addHabitItem, object: item)
            HabitScheduler.shared.startSchedule(for: item)
        } catch {
            print("error: \(error)")
        }
    }
    
    func setupRecordIfNeed(habit: Habit) {
        guard let service = habit.goalUnit.healthService else {
            return
        }
        
        Task {
            var startDate = habit.startedDate
                        
            while !startDate.isFutureDay {
                let setDate = startDate.startOfDay
                
                if setDate.isDateValid(habit) {
                    let newValue = await service.fetchData(for: startDate.endOfDay)
                    
                    if let record = habit.records.first(where: { $0.date.isSameDay(date: setDate) }) {
                        if record.value != newValue {
                            print("record đã có ngày \(setDate.format("dd MMMM yyyy")): \(newValue)")
                            record.value = newValue
                            HabitRecordDAO.shared.updateObject(item: record)
                        }
                    } else {
                        print("record mới tạo ngày \(setDate.format("dd MMMM yyyy")): \(newValue)")
                        HabitRecordDAO.shared.addObject(habitID: habit.id, value: newValue, date: setDate, createdAt: Date())
                    }
                }
                
                startDate = startDate.nextDay
            }
        }
    }
    
    // MARK: - Update habit
    func updateObject(item: Habit) {
        let object = item.rlmObject()
        
        do {
            try self.addObjectAndUpdate(object)
//            setupRecordIfNeed(habit: item)
//            removeRecordIfNeed(habit: item)
//            print("Đã update habit:\(item.name) thành công")
            NotificationCenter.default.post(name: .updateHabitItem, object: item)
            HabitScheduler.shared.startSchedule(for: item)
        } catch {
            print("error: \(error)")
        }
    }
    
    func removeRecordIfNeed(habit: Habit) {
        for record in habit.records {
            if record.date.isDateValid(habit) {
                print("Record ngày \(record.date.day) hợp lệ")
            } else {
                HabitRecordDAO.shared.deleteObject(item: record)
            }
        }
    }
    
    // MARK: - Delete Habit
    func deleteObject(item: Habit) {
        guard let object = try? self.objectWithPrimaryKey(type: RlmHabit.self, key: item.id) else {
            return
        }
        
        do {
            let realm = try Realm()
            try realm.safeTransaction {
                realm.delete(object.records)
                realm.delete(object)
            }
            
            HabitScheduler.shared.deleteSchedule(for: item)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didDeleteRecord, object: item.records)
                NotificationCenter.default.post(name: .deleteHabitItem, object: item)
            }
            
            print("Đã xoá habit: \(item.name)")
        } catch {
            print("error: \(error)")
        }
    }
}

// MARK: - Get
extension HabitDAO {
    func getAll() -> [Habit] {
        guard let listItem = try? self.objects(type: RlmHabit.self) else {
            return []
        }
        
        return listItem.map({ Habit(rlm: $0) })
    }
    
    func getHabit(id: String) -> Habit? {
        guard let object = try? self.objectWithPrimaryKey(type: RlmHabit.self, key: id) else {
            return nil
        }
        
        return Habit(rlm: object)
    }
    
    func getHabitDay(_ day: Date) -> [Habit] {
        let habits = getAll()
        
        return habits.filter { habit in
            day.isDateValid(habit)
        }
    }
    
    func isCreated(_ habit: Habit) -> Bool {
        let object = try? self.objectWithPrimaryKey(type: RlmHabit.self, key: habit.id)
        return object != nil
    }
}

extension Date {
    func isDateValid(_ habit: Habit) -> Bool {
        let compareResult = habit.startedDate.compare(self)
        let dayCondition = compareResult == .orderedAscending || habit.startedDate.isSameDay(date: self)
        
        let repeatType = habit.frequency.type
        
        switch repeatType {
        case .daily:
            return dayCondition && habit.frequency.daily.isSelectedDay(self)
        case .weekly:
            // Tìm những ngày đã có record trong cùng 1 tuần
            let records = habit.records.filter({ $0.createdAt.isSameWeek(date: self)})
            
            // Nếu ngày này là 1 trong những ngày đã record
            if records.contains(where: { $0.createdAt.isSameDay(date: self)}) {
                return true
            }
            
            return dayCondition && records.filter({ $0.isCompleted }).count < habit.frequency.weekly.frequency
        case .monthly:
            return dayCondition && habit.frequency.monthly.isSelectedDay(self)
        }
    }
}
