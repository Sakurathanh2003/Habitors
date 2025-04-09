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
    var selectHabit = PublishSubject<Habit>()
    
    var selectOverview = PublishSubject<()>()
}

struct HomeViewModelOutput: InputOutputViewModel {
    
}

struct HomeViewModelRouting: RoutingOutput {
    var routeToCreate = PublishSubject<()>()
    var routeToHabitRecord = PublishSubject<HabitRecord>()
    var routeToOverview = PublishSubject<()>()
    
    var showAlert = PublishSubject<String>()
}

final class HomeViewModel: BaseViewModel<HomeViewModelInput, HomeViewModelOutput, HomeViewModelRouting> {
    @Published var currentTab: HomeTab = .home
    @Published var dateInMonth = [Date]()
    @Published var selectedDate: Date = Date().nextDay
    
    @Published var tasks = [Habit]()
    @Published var todayTasks = [Habit]()
    
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
        
        getTasks()
        configNotification()
    }
    
    private func configNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateHabitItem(notification:)),
                                               name: .updateHabitItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateHabitItem(notification:)),
                                               name: .deleteHabitItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateHabitItem(notification:)),
                                               name: .addHabitItem, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changedHabitRecord(notification:)),
                                               name: .didUpdateRecord, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changedHabitRecord(notification:)),
                                               name: .didAddRecord, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changedHabitRecord(notification:)),
                                               name: .didDeleteRecord, object: nil)
    }
    
    @objc func changedHabitRecord(notification: Notification) {
        getTasks()
    }
    
    @objc func updateHabitRecord(notification: Notification) {
        if let id = notification.object as? String, let habit = HabitDAO.shared.getHabit(id: id) {
            if let index = self.tasks.firstIndex(where: { $0.id == id }) {
                self.tasks[index] = habit
            }
            
            if let index = self.todayTasks.firstIndex(where: { $0.id == id }) {
                self.todayTasks[index] = habit
            }
        }
    }
    
    @objc func updateHabitItem(notification: Notification) {
        getTasks()
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
        
        input.selectOverview.subscribe(onNext: { [unowned self] in
            self.routing.routeToOverview.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.selectHabit.subscribe(onNext: { [unowned self] selectedHabit in
            if let record = selectedHabit.records.first(where: { $0.date.isSameDay(date: selectedDate) }) {
                self.routing.routeToHabitRecord.onNext(record)
            } else {
                if let record = HabitRecordDAO.shared.addObject(habitID: selectedHabit.id, value: 0, date: selectedDate, createdAt: Date()) {
                    self.routing.routeToHabitRecord.onNext(record)
                }
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func getTasks() {
        let dao = HabitDAO()
        self.tasks = dao.getHabitDay(selectedDate)
        self.todayTasks = dao.getHabitDay(Date())
    }
}

// MARK: - Get
extension HomeViewModel {
    func isSelected(_ tab: HomeTab) -> Bool {
        return currentTab == tab
    }
    
    func isSelectedDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    func needToDoTodayHabit() -> [Habit] {
        let todayHabits = self.todayTasks.filter { habit in
            let record = habit.records.first(where: { $0.date.isSameDay(date: Date() )})
            let goal = habit.goalValue - (record?.value ?? 0) // Ý là cần thực hiện bao nhiêu lần nữa
            return goal > 0
        }
        
        return todayHabits
    }
}
