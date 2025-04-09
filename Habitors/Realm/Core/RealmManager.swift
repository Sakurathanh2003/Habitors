//
//  RealmManager.swift
//  VoiceChangeLite
//
//  Created by Thanh Vu on 24/02/2021.
//

import Foundation
import RealmSwift
import Realm

enum RealmSchemaVersion: UInt64 {
    case first = 0
}

class RealmManager {
    static func configRealm() {
        var config = Realm.Configuration.defaultConfiguration
        config.schemaVersion = RealmSchemaVersion.first.rawValue
        
        if let fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.thanh.habit") {
            config.fileURL = fileURL
        }
        
        config.migrationBlock = { _, _ in
            
        }
        
        Realm.Configuration.defaultConfiguration = config
        
        do {
            _ = try Realm()
        } catch {
            print("error \(error)")
            fatalError()
        }
    }
}
