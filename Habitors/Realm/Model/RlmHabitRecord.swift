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
    @Persisted var date: Date
    @Persisted var status: String // "completed" hoặc "missed"
    @Persisted var value: Double // Số
    @Persisted var createdAt: Date = Date()
    
    @Persisted(originProperty: "records") var habit: LinkingObjects<RlmHabit>
}
