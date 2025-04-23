//
//  HomeActivityViewModel.swift
//  Habitors
//
//  Created by Thanh Vu on 23/4/25.
//
import SwiftUI
import RxSwift

class HomeActivityViewModel: NSObject, ObservableObject {
    @Published var isVietnameseLanguage: Bool = User.isVietnamese
    @Published var isTurnDarkMode: Bool = User.isTurnDarkMode
    @Published var habits: [Habit] = []
    @Published var currentHabit: Habit?
    
    override init() {
        super.init()
        habits = HabitDAO.shared.getAll()
        configNotificationCenter()
    }
   
    func configNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateSetting), name: .updateLanguage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSetting), name: .updateDarkMode, object: nil)
    }
    
    @objc func updateSetting() {
        self.isVietnameseLanguage = User.isVietnamese
        self.isTurnDarkMode = User.isTurnDarkMode
    }
    
    func translate(_ key: String) -> String {
        return Translator.translate(key: key, isVietnamese: isVietnameseLanguage)
    }
}
