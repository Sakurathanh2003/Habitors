//
//  RlmMoodRecord.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 18/4/25.
//

import UIKit
import RealmSwift
import Realm

final class RlmMoodRecord: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var createdDate: Date = Date()
    @Persisted var value: String!
}


