//
//  MoodRecordDAO.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 18/4/25.
//
import Foundation
import Realm
import RealmSwift

final class MoodRecordDAO: RealmDao {
    static let shared = MoodRecordDAO()
    
    @discardableResult
    func addObject(mood: Mood) -> MoodRecord? {
        let object = RlmMoodRecord()
        object.createdDate = Date()
        object.value = mood.rawValue
        
        do {
            try self.addObjectAndUpdate(object)
            let record = getMoodRecord(id: object.id.stringValue)
            return record
        } catch {
            print("❌ Lỗi thêm mood record: \(error)")
            return nil
        }
    }
    
    func deleteObject(item: MoodRecord) {
        guard let object = try? self.objectWithPrimaryKey(type: RlmMoodRecord.self, key: ObjectId(string: item.id)) else {
            return
        }
                
        do {
            try self.deleteObject(object)
        } catch {
            print("❌ Lỗi xoá mood record: \(error)")
        }
    }
    
    func getMoodRecord(id: String) -> MoodRecord? {
        guard let objectID = try? ObjectId(string: id),
              let object = try? self.objectWithPrimaryKey(type: RlmMoodRecord.self, key: objectID) else {
            return nil
        }
        
        return MoodRecord(id: id, createdDate: object.createdDate,
                          value: Mood(rawValue: object.value) ?? .angry)
    }
    
    func getAll() -> [MoodRecord] {
        guard let listItem = try? self.objects(type: RlmMoodRecord.self) else {
            return []
        }
        
        return listItem.map({ MoodRecord(id: $0.id.stringValue, createdDate: $0.createdDate,
                                         value: Mood(rawValue: $0.value) ?? .angry) })
    }
}
