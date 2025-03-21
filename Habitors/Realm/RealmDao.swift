//
//  RealmDao.swift
//
//  Created by Thanh Vu on 2/24/21.
//  Copyright © 2021 Solar. All rights reserved.
//

import Foundation
import Realm

extension Realm {
    func safeTransaction(_ closure: () throws -> Void) throws {
        if self.isInWriteTransaction {
            try closure()
        } else {
            try self.write(closure)
        }
    }
}

class RealmDao {
    func objects<T: Object>(type: T.Type) throws -> Results<T> {
        let realm = try Realm()
        return realm.objects(type)
    }

    func objectWithPrimaryKey<T:Object>(type: T.Type, key: Any) throws -> T? {
        let realm = try Realm()
        return realm.object(ofType: type, forPrimaryKey: key)
    }

    func deleteAll<T: Object>(type: T.Type) throws {
        let realm = try Realm()
        let results = realm.objects(type)
        try realm.safeTransaction {
            realm.delete(results)
        }
    }

    func addObject(_ object: Object) throws {
        try self.addObjects([object])
    }

    func addObjects(_ objects: [Object]) throws {
        let realm = try Realm()
        try realm.safeTransaction {
            realm.add(objects)
        }
    }

    func addObjectAndUpdate(_ object: Object) throws {
        let realm = try Realm()
        try realm.safeTransaction {
            realm.add(object, update: .all)
        }
    }
    
    func addObjectsAndUpdate(_ objects: [Object]) throws {
        let realm = try Realm()
        try realm.safeTransaction {
            realm.add(objects, update: .all)
        }
    }

    func deleteObjects(_ objects: [Object]) throws {
        let realm = try Realm()
        try realm.safeTransaction {
            realm.delete(objects)
        }
    }
    
    func deleteObject(_ object: Object) throws {
        let realm = try Realm()
        try realm.safeTransaction {
            realm.delete(object)
        }
    }

    func objects<T: Object>(type: T.Type, predicate: NSPredicate) throws -> Results<T> {
        let realm = try Realm()
        return realm.objects(type).filter(predicate)
    }
    
    func deleteObjects<T: Object>(type: T.Type, predicate: NSPredicate) throws {
        let realm = try Realm()
        let results = realm.objects(type).filter(predicate)
        let objects = Array(results)
        
        try realm.safeTransaction {
            realm.delete(objects)
        }
    }
}
