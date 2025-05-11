//
//  HabitRecord.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 26/3/25.
//

import Foundation
import RealmSwift

class RlmHabitRecord: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var habitID: String
    @Persisted var date: Date
    @Persisted var value: Double // Số
}

extension RlmHabitRecord {
    convenience init(from record: HabitRecord) {
        self.init()
        self.id = (try? ObjectId.init(string: record.id)) ?? ObjectId.generate()
        self.date = record.date
        self.value = record.value
        self.habitID = record.habitID
    }
}
