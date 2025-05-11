//
//  RlmHabit.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 26/3/25.
//

import UIKit
import RealmSwift
import Realm

final class RlmHabit: Object {
    @Persisted(primaryKey: true) var id: String!
    @Persisted var name: String!
    @Persisted var icon: String!
    @Persisted var goalUnit: GoalUnit!
    @Persisted var goalValue: Double = 0
    
    @Persisted var frequency: String!
    @Persisted var startDate: Date = Date()
    @Persisted var isTemplate: Bool!
    @Persisted var reminder: String!
}                                          
