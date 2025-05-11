//
//  HabitRecordDAO.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 26/3/25.
//

import Foundation
import Realm
import RealmSwift

extension Notification.Name {
    static let didAddRecord = Notification.Name("didAddRecord")
    static let didUpdateRecord = Notification.Name("didUpdateRecord")
    static let didDeleteRecord = Notification.Name("didDeleteRecord")
}

final class HabitRecordDAO: RealmDao {
    static let shared = HabitRecordDAO()
    
    @discardableResult
    func addObject(habitID: String, value: Double, date: Date) -> HabitRecord? {
        let object = RlmHabitRecord()
        object.id = .generate()
        object.date = date
        object.value = value
        object.habitID = habitID
        
        do {
            try self.addObjectAndUpdate(object)
            print("✅ Đã thêm record ngày \(date.day)-\(date.month)-\(date.year) vào habit")
            
            let record = getHabitRecord(id: object.id.stringValue)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didAddRecord, object: record)
            }
            
            return record
        } catch {
            print("❌ Lỗi thêm record: \(error)")
            return nil
        }
    }
    
    func updateObject(item: HabitRecord) {
        let object = RlmHabitRecord(from: item)
        
        do {
            try self.addObjectAndUpdate(object) // Realm sẽ tự update theo ID (ObjectId)
            print("✅ update thành công")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didUpdateRecord, object: item)
            }
        } catch {
            print("❌ Lỗi update record: \(error)")
        }
    }
}

// MARK: - Delete
extension HabitRecordDAO {
    func deleteObject(item: HabitRecord) {
        let habitName = item.habit?.name ?? "Unknow"
        
        do {
            try self.deleteObject(id: item.id)
            
            print("✅ Đã xoá record(\(item.id) ngày \(item.date.day)-\(item.date.month)-\(item.date.year) của  habit \(habitName)")

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didDeleteRecord, object: [item])
            }
        } catch {
            print("❌ Lỗi xoá record: \(error)")
        }
    }
    
    func deleteObject(from habit: Habit) throws {
        let objects = habit.records.compactMap({ $0.id })
            .compactMap({ try? ObjectId(string: $0) })
            .compactMap({ try? self.objectWithPrimaryKey(type: RlmHabitRecord.self, key: $0) })
        
        try self.deleteObjects(objects)
    }
    
    func deleteObject(id: String) throws {
        guard let object = try? self.objectWithPrimaryKey(type: RlmHabitRecord.self, key: ObjectId(string: id)) else {
            return
        }
        
        try self.deleteObject(object)
    }
}

// MARK: - Get
extension HabitRecordDAO {
    func getHabitRecord(id: String) -> HabitRecord? {
        guard let objectID = try? ObjectId(string: id),
              let object = try? self.objectWithPrimaryKey(type: RlmHabitRecord.self, key: objectID) else {
            return nil
        }
        
        return HabitRecord(from: object)
    }
    
    func getRecord(habitID: String, date: Date) -> HabitRecord? {
        let records = getRecord(habitID: habitID)
        return records.first(where: { $0.date.isSameDay(date: date) })
    }
    
    func getAll() -> [HabitRecord] {
        guard let items = try? self.objects(type: RlmHabitRecord.self) else {
            return []
        }
        
        return items.map({ HabitRecord(from: $0) })
    }
    
    func getRecord(habitID: String) -> [HabitRecord] {
        return getAll().filter({ $0.habitID == habitID })
    }
}

