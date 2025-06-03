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
    
    func checkReadPermission(completion: ((Bool) -> Void)?)
    
    func checkReadPermission() async -> Bool
    
    func fetchData(for date: Date) async -> Double
    func startObserver() async
    func requestAuthorization(completion: @escaping (Bool) -> Void)
}
