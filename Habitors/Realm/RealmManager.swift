//
//  RealmManager.swift
//  VoiceChangeLite
//
//  Created by Thanh Vu on 24/02/2021.
//

import Foundation
import RealmSwift
import Realm
import TLLogging

enum RealmSchemaVersion: UInt64 {
    case first = 0
}

class RealmManager {
    static func configRealm() {
        var config = Realm.Configuration.defaultConfiguration
        config.schemaVersion = RealmSchemaVersion.first.rawValue
        config.migrationBlock = { _, _ in
            
        }
        
        Realm.Configuration.defaultConfiguration = config
        do {
            _ = try Realm()
        } catch {
            TLLogging.log("Realm need migration. Delete app if in dev mode")
            fatalError()
        }
    }
}
