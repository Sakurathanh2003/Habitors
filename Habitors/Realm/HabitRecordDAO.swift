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
    func addObject(habitID: String, value: Double, date: Date, createdAt: Date) -> HabitRecord? {
        let object = RlmHabitRecord()
        object.id = .generate()
        object.status = ""
        object.createdAt = createdAt
        object.date = date
        object.value = value
        
        do {
            try self.appendObject(to: RlmHabit.self,
                                  parentKey: habitID,
                                  listKeyPath: \.records,
                                  object: object)
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
    
    func deleteObject(item: HabitRecord) {
        guard let object = try? self.objectWithPrimaryKey(type: RlmHabitRecord.self, key: ObjectId(string: item.id)) else {
            return
        }
        
        let habitName = item.habit?.name ?? "Unknow"
        
        do {
            try self.deleteObject(object)
            
            print("✅ Đã xoá record(\(item.id) ngày \(item.date.day)-\(item.date.month)-\(item.date.year) của  habit \(habitName)")

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didDeleteRecord, object: [item])
            }
        } catch {
            print("❌ Lỗi xoá record: \(error)")
        }
    }
    
    func getHabitRecord(id: String) -> HabitRecord? {
        guard let objectID = try? ObjectId(string: id),
              let object = try? self.objectWithPrimaryKey(type: RlmHabitRecord.self, key: objectID) else {
            return nil
        }
        
        return HabitRecord(from: object)
    }
}

extension RlmHabitRecord {
    convenience init(from record: HabitRecord) {
        self.init()
        self.id = (try? ObjectId.init(string: record.id)) ?? ObjectId.generate()
        self.date = record.date
        self.status = record.status
        self.value = record.value
        self.createdAt = record.createdAt
    }
}

