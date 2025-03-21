//
//  HabitDAO.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 20/3/25.
//

import UIKit
import RealmSwift

final class HabitDAO: RealmDao {
    func addObject(item: Habit) {
        let object = item.rlmObject()
        try? self.addObject(object)
    }
    
    func updateObject(item: Habit) {
        let object = item.rlmObject()
        try? self.addObjectAndUpdate(object)
    }
    
    func deleteObject(item: Habit) {
        let object = item.rlmObject()
        try? self.deleteObject(object)
    }
    
    func getAll() -> [Habit] {
        guard let listItem = try? self.objects(type: RlmHabit.self) else {
            return []
        }
        
        return listItem.map({ RlmHabit(rlm: $0) })
    }
}

final class RlmHabit: Object {
    @objc dynamic var id: String!
    @objc dynamic var name: String!
    @objc dynamic var icon: String!
    @objc dynamic var goalUnit: String!
    @objc dynamic var goalValue: Int!
    @objc dynamic var color: Int?
    @objc dynamic var frequency: Frequency!

    override init() {
        super.init()
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension Habit {
    func rlmObject() -> RlmHabit {
        let object = RlmHabit()
        object.id = self.id
        object.name = self.name
        object.icon = self.icon
        object.frequency = self.frequency
        return object
    }
    
    init(rlm: RlmHabit) {
        self.id = rlm.id
        self.name = rlm.name
        self.icon = rlm.icon
        self.goalUnit = GoalUnit(rawValue: rlm.goalUnit) ?? .count
        self.goalValue = rlm.goalValue
        self.color = rlm.color
        self.isTemplate = false
        self.frequency = rlm.frequency
    }
}
