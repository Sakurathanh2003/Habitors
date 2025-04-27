//
//  HealthProvider.swift
//  Habitors
//
//  Created by Thanh Vu on 22/4/25.
//
import Foundation
import HealthKit

protocol HealthService {
    var didRequestPermission: Bool { get set }
    
    func checkWritePermission(completion: ((Bool) -> Void)?)
    func checkReadPermission(completion: ((Bool) -> Void)?)
    
    func checkWritePermission() async -> Bool
    func checkReadPermission() async -> Bool
    
    func fetchData(for date: Date) async -> Double
    func saveData(_ data: Double, in date: Date, completion: ((Bool, Error?) -> Void)?)
    
    func startObserver() async
    func requestAuthorization(completion: @escaping (Bool, Bool) -> Void)
}
