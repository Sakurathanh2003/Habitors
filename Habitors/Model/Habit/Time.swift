//
//  Time.swift
//  Habitors
//
//  Created by Thanh Vu on 10/5/25.
//
import Foundation

struct Time: Codable {
    var hour: Int
    var minutes: Int
    
    init(hour: Int, minutes: Int) {
        self.hour = hour
        self.minutes = minutes
    }
    
    init(rlmValue: String) {
        let array = rlmValue.split(separator: ":")
        self.hour = Int(array[0]) ?? 0
        self.minutes = Int(array[1]) ?? 0
    }
    
    static func morning() -> Time {
        return .init(hour: 8, minutes: 00)
    }
    
    static func afternoon() -> Time {
        return .init(hour: 13, minutes: 00)
    }
    
    static func evening() -> Time {
        return .init(hour: 19, minutes: 00)
    }
    
    var description: String {
        return String(format: "%02d:%02d", hour, minutes)
    }
    
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.hour == rhs.hour && lhs.minutes == rhs.minutes
    }
    
    func rlmValue() -> String {
        return "\(self.hour):\(self.minutes)"
    }
}
