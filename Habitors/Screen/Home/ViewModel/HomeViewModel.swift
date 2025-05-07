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
    
    var selectArticle = PublishSubject<Article>()
    
    var overallHabit = PublishSubject<Habit?>()
}

struct HomeViewModelOutput: InputOutputViewModel {
    
}

struct HomeViewModelRouting: RoutingOutput {
    var routeToCreate = PublishSubject<()>()
    var routeToHabitRecord = PublishSubject<HabitRecord>()
    
    var showAlert = PublishSubject<String>()
    var routeToArticle = PublishSubject<Article>()
    
    var routeToMoodie = PublishSubject<()>()
    var routeToQuickNote = PublishSubject<()>()
    
    var routeToSetting = PublishSubject<()>()
    var routeToListHabit = PublishSubject<()>()
}

final class HomeViewModel: BaseViewModel<HomeViewModelInput, HomeViewModelOutput, HomeViewModelRouting> {
    @Published var currentTab: HomeTab = .home
    @Published var dateInMonth = [Date]()
    @Published var selectedDate: Date = Date().nextDay
    
    @Published var tasks = [Habit]()
    @Published var todayTasks = [Habit]()
    
    @Published var currentTool: Tool?
    
    // Overall
    @Published var allHabit = [Habit]()
    @Published var currentHabit: Habit?
    @Published var currentMonth = Date()
    @Published var daysInMonth = [Date]()
    @Published var currentYear = Date()
    @Published var dateInYear = [Date]()
    
    @Published var totalDoneDate = [Date]()
    @Published var bestStreak: Int = 0
    @Published var currentStreak: Int = 0
    @Published var doneInMonth: Int = 0

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
            self.currentTab = tab
            
            if currentTab == .overall {
                self.prepareDataForOverall()
            }
        }).disposed(by: self.disposeBag)
        
        input.selectDate.subscribe(onNext: { [unowned self] date in
            self.selectedDate = date
            self.getTasks()
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
        
        input.selectArticle.subscribe(onNext: { [unowned self] item in
            self.routing.routeToArticle.onNext(item )
        }).disposed(by: self.disposeBag)
        
        // Overall
        input.overallHabit.subscribe(onNext: { [unowned self] habit in
            self.currentHabit = habit
            
            self.updateSummaryData()
        }).disposed(by: self.disposeBag)
    }
    
    private func getTasks() {
        print("Cập nhật dữ liệu về habit trong màn home thành công")
        self.allHabit = HabitDAO.shared.getAll()
        self.tasks = HabitDAO.shared.getHabitDay(selectedDate)
        self.todayTasks = HabitDAO.shared.getHabitDay(Date())
        
        if let habit = allHabit.first(where: { $0.id == currentHabit?.id }) {
            self.currentHabit = habit
        } else {
            self.currentHabit = nil
        }
    }
}

// MARK: - Overall
extension HomeViewModel {
    private func prepareDataForOverall() {
        updateDaysInMonth()
        updateDateInYear()
        updateSummaryData()
    }
    
    func updateNextYear() {
        self.currentYear = self.currentYear.nextYear
        updateDateInYear()
    }
    
    func updatePreviousYear() {
        self.currentYear = self.currentYear.previousYear
        updateDateInYear()
    }
    
    func updateNextMonth() {
        self.currentMonth = self.currentMonth.nextMonth
        updateDaysInMonth()
        updateDoneInMonth()
    }
    
    func updatePreviousMonth() {
        self.currentMonth = self.currentMonth.previousMonth
        updateDaysInMonth()
        updateDoneInMonth()
    }
    
    private func updateDateInYear() {
        let year = currentYear.year
        self.dateInYear = Calendar.current.getFullWeeksOfYear(year: year)
    }
    
    private func updateDaysInMonth() {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        var days = range.map { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
        }
        
        while let day = days.first, !day.isStartOfWeek {
            days.insert(day.previousDay, at: 0)
        }
        
        while let day = days.last, !day.isEndOfWeek {
            days.append(day.nextDay)
        }
        
        self.daysInMonth = days
    }
    
    // Summary
    private func updateBestStreak() {
        let days = fillMissingDates(from: totalDoneDate)
        var streak = 0, best = 0
        
        for day in days {
            if habitsInDay(day).isEmpty {
                continue
            }
            
            if totalDoneDate.contains(day) {
                streak += 1
            } else {
                streak = 0
            }
            
            best = max(best, streak)
        }
        
        self.bestStreak = best
    }
    
    private func updateCurrentStreak() {
        func isDoneDate(_ date: Date) -> Bool {
            return totalDoneDate.contains(where: { $0.isSameDay(date: date )})
        }
        
        if totalDoneDate.isEmpty {
            self.currentStreak = 0
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var date = today
        
        // Nếu hôm nay chưa hoàn thành thì lấy ngày hôm trước làm mốc
        if !isDoneDate(date) {
            date = today.yesterDay
        }
        
        var streak = 0
        
        while isDoneDate(date) || habitsInDay(date).isEmpty {
            if !habitsInDay(date).isEmpty {
                streak += 1
            }
           
            date = calendar.date(byAdding: .day, value: -1, to: date)!
            
            if let firstDay = totalDoneDate.first, date < firstDay {
                break
            }
        }
        
        self.currentStreak = streak
    }
    
    private func updateDoneInMonth() {
        let days = totalDoneDate.filter({ $0.isSameMonth(as: currentMonth) })
        self.doneInMonth = days.count
    }
    
    func updateSummaryData() {
        var habits = [Habit]()
        
        if let currentHabit {
            habits.append(currentHabit)
        } else {
            habits.append(contentsOf: allHabit)
        }
        
        let records = habits.flatMap({ $0.records })
        let days = completedDays(records: records, habits: habits)
        self.totalDoneDate = days.sorted()
        
        updateDoneInMonth()
        updateCurrentStreak()
        updateBestStreak()
    }
    
    func habitsInDay(_ date: Date) -> [Habit] {
        return allHabit.filter({ date.isDateValid($0) })
    }
    
    func percentInDate(_ date: Date) -> Double {
        var habit = [Habit]()
        
        if let currentHabit {
            habit.append(currentHabit)
        } else {
            habit.append(contentsOf: allHabit)
        }
        
        let habitsInDay = habit.filter { date.isDateValid($0) }
        var percents: Double = 0
        
        for habit in habitsInDay {
            if let record = habit.records.first(where: { $0.date.isSameDay(date: date) }) {
                percents += record.completedPercent
            }
        }
        
        if habitsInDay.isEmpty {
            return 0
        }
        
        return percents / Double(habitsInDay.count)
    }
    
    func hasHabit(in day: Date) -> Bool {
        var habit = [Habit]()
        
        if let currentHabit {
            habit.append(currentHabit)
        } else {
            habit.append(contentsOf: allHabit)
        }
        
        let habitsInDay = habit.filter { day.isDateValid($0) }
        return !habitsInDay.isEmpty
    }
    
    func completedDays(records: [HabitRecord], habits: [Habit]) -> [Date] {
        let doneRecords = records.filter {
            $0.completedPercent >= 1
        }
        
        let dates = Set(doneRecords.map { $0.date.startOfDay }) // loại trùng
        var habitInDate = [Date: [Habit]]()
        
        for habit in habits {
            for date in dates where date.isDateValid(habit) {
                habitInDate[date, default: []].append(habit)
            }
        }
        
        let grouped = groupRecordsByDay(doneRecords)
        
        return grouped.compactMap { date, recordsInDay in
            habitInDate[date]?.count == recordsInDay.count ? date : nil
        }
    }
    
    func fillMissingDates(from dates: [Date]) -> [Date] {
        guard let minDate = dates.min()?.startOfDay, let maxDate = dates.max()?.startOfDay else { return [] }
        
        var filledDates: [Date] = []
        var currentDate = minDate
        let calendar = Calendar.current
        
        while currentDate <= maxDate {
            filledDates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return filledDates
    }
    
    func groupRecordsByDay(_ records: [HabitRecord]) -> [Date: [HabitRecord]] {
        return Dictionary(grouping: records) { record in
            record.date.startOfDay // chuẩn hóa về đầu ngày
        }
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
    
    var title: String {
        if currentTab == .home {
            return Date().format("EEEE dd, yyyy", isVietnamese: isVietnameseLanguage)
        }
        
        if let currentHabit, currentTab == .overall {
            return currentHabit.name
        }
        
        return translate(currentTab.rawValue.capitalized)
    }
}
