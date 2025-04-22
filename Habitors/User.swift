//
//  User.swift
//  Habitors
//
//  Created by Thanh Vu on 22/4/25.
//

import Foundation

extension Notification.Name {
    static let updateLanguage = Notification.Name("updateLanguage")
    static let updateDarkMode = Notification.Name("updateDarkMode")
}

class User {
    static var isVietnamese: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isVietnamese")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isVietnamese")
            NotificationCenter.default.post(name: .updateLanguage, object: nil)
        }
    }
    
    static var isTurnDarkMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isTurnDarkMode")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isTurnDarkMode")
            NotificationCenter.default.post(name: .updateDarkMode, object: nil)
        }
    }
}
