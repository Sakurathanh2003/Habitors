//
//  HomeViewModel.swift
//  Habitors
//
//  Created by CucPhung on 13/3/25.
//

import UIKit
import RxSwift
import SwiftUI

struct HomeViewModelInput: InputOutputViewModel {
    var selectTab = PublishSubject<HomeTab>()
    var selectDate = PublishSubject<Date>()
}

struct HomeViewModelOutput: InputOutputViewModel {

}

struct HomeViewModelRouting: RoutingOutput {
    var routeToCreate = PublishSubject<()>()
}

final class HomeViewModel: BaseViewModel<HomeViewModelInput, HomeViewModelOutput, HomeViewModelRouting> {
    @Published var currentTab: HomeTab = .tools
    @Published var dateInMonth = [Date]()
    @Published var selectedDate: Date?
    
    @Published var tasks = [Task]()
    @Published var todayTasks = [Task]()
    
    @Published var showingToolItem: Tool.Item?
    
    @Published var tools: [Tool] = [
        .init(id: UUID().uuidString, name: "Meditations", type: .music, items: [
            .init(name: "Energy Ball", description: "7 min"),
            .init(name: "Breath Cycle", description: "5 min"),
            .init(name: "Mindfulness", description: "5 min"),
            .init(name: "IDK", description: "5 min")
        ]),
        .init(id: UUID().uuidString, name: "Soundscapes", type: .music, items: [
            .init(name: "Energy Ball", description: "7 min"),
            .init(name: "Breath Cycle", description: "5 min"),
            .init(name: "Mindfulness", description: "5 min"),
            .init(name: "IDK", description: "5 min")
        ])
    ]
    
    override init() {
        super.init()
        getDateInMonth()
        configInput()
    }
    
    private func getDateInMonth() {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Lấy năm và tháng hiện tại
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        
        // Lấy ngày đầu tiên của tháng
        guard let startDate = calendar.date(from: components) else {
            return
        }
        
        // Lấy số ngày trong tháng hiện tại
        guard let range = calendar.range(of: .day, in: .month, for: startDate) else { 
            return
        }
        
        // Tạo danh sách các ngày trong tháng
        self.dateInMonth = range.compactMap { day -> Date? in
            var dayComponent = components
            dayComponent.day = day
            return calendar.date(from: dayComponent)
        }
    }
    
    private func configInput() {
        input.selectTab.subscribe(onNext: { [unowned self] tab in
            withAnimation {
                self.currentTab = tab
            }
        }).disposed(by: self.disposeBag)
        
        input.selectDate.subscribe(onNext: { [unowned self] date in
            self.selectedDate = date
            self.getTasks()
        }).disposed(by: self.disposeBag)
    }
    
    private func getTasks() {
        
    }
}

// MARK: - Get
extension HomeViewModel {
    func isSelected(_ tab: HomeTab) -> Bool {
        return currentTab == tab
    }
    
    func isSelectedDate(_ date: Date) -> Bool {
        guard let selectedDate else {
            return false
        }
        
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
}
