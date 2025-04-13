//
//  HomeActivityView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import Foundation
import RxSwift
import SwiftUI
import Charts

fileprivate struct Const {
    static let horizontalPadding: CGFloat = 24.0
    static let percentTextHeight: CGFloat = 16
    static let dayTextWidth: CGFloat = 30
}

enum TimePeriod: String, CaseIterable {
    case week
    case month
    case year
}

struct ChartData {
    var key: String
    var value: Double
    var target: Double
}

struct ProgressCircle: View {
    var progress: CGFloat // Giá trị tiến trình (0.0 -> 1.0)
    var lineWidth: CGFloat = 12
    
    var gradient: AngularGradient {
            AngularGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0),
                    Color("Primary")
                ]),
                center: .center,
                startAngle: .degrees(360 * progress),
                endAngle: .degrees(0)
            )
        }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("Gray02"), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}

struct SummaryView: View {
    enum SummaryType {
        case bestStreak
        case currentStreak
        case doneInMonth
        case totalDone
        
        var unit: String {
            switch self {
            case .bestStreak:
                "Day"
            case .currentStreak:
                "Day"
            case .doneInMonth:
                "Day"
            case .totalDone:
                "Day"
            }
        }
        
        var title: String {
            switch self {
            case .bestStreak:
                "Best Streak"
            case .currentStreak:
                "Current Streak"
            case .doneInMonth:
                "Done in month"
            case .totalDone:
                "Total Done"
            }
        }
    }
    
    @Binding var currentMonth: Date
    
    var habits: [Habit]
    var type: SummaryType
    
    var color: Color {
        return .red
    }
    
    var records: [HabitRecord] {
        return habits.flatMap({ $0.records })
    }
    
    var imageName: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(imageName)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(color)
                    )
                    .padding(.bottom, 20)
                
                Spacer()
            }
            
            Text(value.text).gilroyBold(16)
            + Text(" \(type.unit)").gilroyRegular(10)
               
            Text(type.title)
                .gilroyRegular(10)
                .padding(.top, 3)
        }
        .padding(10)
        .background(.white)
        .cornerRadius(5)
    }
    
    var value: Double {
        switch type {
        case .bestStreak:
            let completedDays = completedDays(records: records, habits: habits).sorted()
            let days = fillMissingDates(from: completedDays)
            var streak = 0, best = 0
            
            for day in days {
                if habitsInDay(day).isEmpty {
                    continue
                }
                
                if completedDays.contains(day) {
                    streak += 1
                } else {
                    streak = 0
                }
                
                best = max(best, streak)
            }
            
            return Double(best)

        case .currentStreak:
            let days = completedDays(records: records, habits: habits).sorted()
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            var date = today
            if !days.contains(date) {
                date = today.yesterDay
            }
            
            var streak = 0
            while days.contains(date) || habitsInDay(date).isEmpty {
                if !habitsInDay(date).isEmpty {
                    streak += 1
                }
               
                date = calendar.date(byAdding: .day, value: -1, to: date)!
                
                if let firstDay = days.first, date < firstDay {
                    break
                }
            }
            
            return Double(streak)

        case .doneInMonth:
            let days = completedDays(records: records, habits: habits, month: currentMonth)
            return Double(days.count)

        case .totalDone:
            let days = completedDays(records: records, habits: habits)
            return Double(days.count)
        }

    }
    
    func habitsInDay(_ date: Date) -> [Habit] {
        return habits.filter({ date.isDateValid($0) })
    }
    
    func groupRecordsByDay(_ records: [HabitRecord]) -> [Date: [HabitRecord]] {        
        return Dictionary(grouping: records) { record in
            record.date.startOfDay // chuẩn hóa về đầu ngày
        }
    }
    
    func completedDays(records: [HabitRecord], habits: [Habit], month: Date? = nil) -> [Date] {
        let doneRecords = records.filter {
            $0.completedPercent >= 1 && (month == nil || $0.date.isSameMonth(as: month!))
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
}

class HomeActivityViewModel: NSObject, ObservableObject {
    @Published var habits: [Habit] = []
    @Published var currentHabit: Habit?
    
    override init() {
        super.init()
        habits = HabitDAO.shared.getAll()
    }
}

// MARK: - HomeActivityView
struct HomeActivityView: View {
    @ObservedObject var viewModel: HomeActivityViewModel
    @State var currentTab = TimePeriod.week
    @State var currentMonth = Date()
    
    @ViewBuilder
    func thumbnailHabitView(habit: Habit) -> some View {
        let isSelected = habit.id == viewModel.currentHabit?.id
        if habit.icon.count == 1 {
            if isSelected {
                Text(habit.icon)
                    .font(.system(size: 24))
                    .frame(width: 24, height: 24)
            } else {
                Color("Gray02")
                    .frame(width: 24, height: 24)
                    .mask(
                        Text(habit.icon).font(.system(size: 24))
                    )
            }
        } else {
            Image(habit.icon)
                .renderingMode(isSelected ? .original : .template)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundStyle(Color("Gray02"))
                .frame(width: 35, height: 35)
        }
    }
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    Image("pie-chart")
                        .renderingMode(viewModel.currentHabit == nil ? .original : .template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color("Gray02"))
                        .frame(width: 24, height: 24)
                        .onTapGesture {
                            viewModel.currentHabit = nil
                        }
                    
                    ForEach(viewModel.habits, id: \.id) { habit in
                        thumbnailHabitView(habit: habit)
                        .onTapGesture {
                            viewModel.currentHabit = habit
                        }
                    }
                    
                }.padding(.horizontal, 20)
            }
            .frame(height: 50)
            .background(
                Color.white
                    .shadow(color: .black.opacity(0.1),radius: 5, y: 10)
            )
            .zIndex(1)
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 20) {
                    Color.clear.frame(height: 1)
                    calendarView
                    
                    if let currentHabit = viewModel.currentHabit {
                        YearStatusView(records: currentHabit.records)
                        summaryView
                        TrendingView(records: currentHabit.records,
                                     habit: currentHabit)
                    } else {
                        LazyVGrid(columns: [.init(), .init()]) {
                            SummaryView(currentMonth: $currentMonth,
                                        habits: viewModel.habits,
                                        type: .doneInMonth)
                            SummaryView(currentMonth: $currentMonth,
                                        habits: viewModel.habits,
                                        type: .totalDone)
                            SummaryView(currentMonth: $currentMonth,
                                        habits: viewModel.habits,
                                        type: .currentStreak)
                            SummaryView(currentMonth: $currentMonth,
                                        habits: viewModel.habits,
                                        type: .bestStreak)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 100)
            }
            .background(Color.gray.opacity(0.1))
        }
    }
    
    // MARK: - Summary View
    @ViewBuilder
    var summaryView: some View {
        if let currentHabit = viewModel.currentHabit {
            LazyVGrid(columns: [.init(), .init()]) {
                SummaryView(currentMonth: $currentMonth,
                            habits: [currentHabit],
                            type: .doneInMonth)
                SummaryView(currentMonth: $currentMonth,
                            habits: [currentHabit],
                            type: .totalDone)
                SummaryView(currentMonth: $currentMonth,
                            habits: [currentHabit],
                            type: .currentStreak)
                SummaryView(currentMonth: $currentMonth,
                            habits: [currentHabit],
                            type: .bestStreak)
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Calendar View
    @ViewBuilder
    var calendarView: some View {
        if let currentHabit = viewModel.currentHabit {
            CalendarView(
                viewModel: CalendarViewModel(
                    mode: .analytic,
                    habits: [currentHabit]),
                         updateMonth: { month in
                self.currentMonth = month
            })
            .padding(20)
            .background(.white)
            .cornerRadius(5)
            .padding(.horizontal, 20)
        } else {
            CalendarView(
                viewModel: CalendarViewModel(
                    mode: .analytic,
                    habits: viewModel.habits),
                         updateMonth: { month in
                self.currentMonth = month
            })
            .padding(20)
            .background(.white)
            .cornerRadius(5)
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    var weekGoalView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Week's goal")
                .gilroySemiBold(18)
                .foregroundStyle(Color("Black"))
                .padding(.leading, Const.horizontalPadding)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(1..<10, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 0) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("👾")
                                )
                            
                            Text("Learn English")
                                .gilroySemiBold(14)
                                .lineLimit(1)
                                .foregroundStyle(Color("Black"))
                                .padding(.top, 10)
                            
                            Text("Complete")
                                .gilroyMedium(10)
                                .lineLimit(1)
                                .foregroundStyle(Color("Success"))
                                .padding(.top, 5)
                        }
                        .padding(.horizontal, 11)
                        .frame(height: 103)
                        .background(
                            Color("Gray01")
                        )
                        .cornerRadius(6)
                    }
                }
                .padding(.horizontal, Const.horizontalPadding)
            }
        }
    }
}

// MARK: - Year status
struct YearStatusView: View {
    var records: [HabitRecord]
    @State var currentYear = Date()
    
    var dateInYear: [Date] {
        return currentYear.calendar.getFullWeeksOfYear(year: currentYear.year)
    }
    
    var numberOfWeek: CGFloat {
        return CGFloat(dateInYear.count / 7)
    }
    
    var body: some View {
        let width = UIScreen.main.bounds.width - 80
        let spacing = 1.0
        let itemWidth = (width - spacing * (numberOfWeek - 1)) / numberOfWeek
        
        VStack(spacing: 10) {
            HStack {
                Text("Yearly status").gilroySemiBold(14)
                Spacer()
                
                HStack(spacing: 2) {
                    Image("ic_arrow_left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .onTapGesture {
                            currentYear = currentYear.previousYear
                        }
                    
                    Text(currentYear.year.format("%d")).gilroyRegular(10)
                    
                    Image("ic_arrow_right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .onTapGesture {
                            currentYear = currentYear.nextYear
                        }
                }
                .padding(5)
                .background(Color("Gray02"))
                .cornerRadius(5)
            }
            
            VStack(spacing: spacing) {
                ForEach(0...6, id: \.self) { dayIndex in
                    HStack(spacing: spacing) {
                        ForEach(0..<Int(numberOfWeek), id: \.self) { weekIndex in
                            let date = dateInYear[weekIndex * 7 + dayIndex]
                            
                            dayView(date)
                        }
                    }
                }
            }
            .frame(width: width,
                   height: itemWidth * 7 + spacing * 6)
        }
        .padding(20)
        .background(.white)
        .cornerRadius(5)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func dayView(_ date: Date) -> some View {
        let record = records.first(where: { $0.date.isSameDay(date: date)})
        let completedPercent = record?.completedPercent ?? 0
        let color = completedPercent >= 1 ? Color("Primary") : Color("Gray02")
        RoundedRectangle(cornerSize: .zero)
            .fill(
                date.year != currentYear.year ? .clear : color
            )
    }
}

// MARK: - Trending View
struct TrendingView: View {
    @State var currentTab = TimePeriod.week
    var records: [HabitRecord]
    var habit: Habit
    let date = Date()
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text("Trending").gilroyBold(16)
                
                Spacer(minLength: 0)
                HStack(spacing: 0) {
                    ForEach(TimePeriod.allCases, id: \.self) { type in
                        TabItemView(type: type, isSelected: currentTab == type)
                            .onTapGesture {
                                currentTab = type
                            }
                    }
                }
                .padding(4)
                .background(Color("Gray02"))
                .cornerRadius(2)
            }
        
            ChartView(data: data)
            .frame(height: 200)
        }
        .padding(20)
        .background(.white)
        .cornerRadius(5)
        .padding(.horizontal, 20)
    }
    
    var data: [ChartData] {
        var data = [ChartData]()
                
        switch currentTab {
        case .week:
            let dates = Calendar.current.getDatesInWeek(containing: Date())
            for date in dates {
                if date.isDateValid(habit) {
                    if let record = records.first(where: { $0.date.isSameDay(date: date)}) {
                        data.append(.init(key: formatShortWeekday(date),
                                          value: record.value,
                                          target: habit.goalValue))
                    } else {
                        data.append(.init(key: formatShortWeekday(date),
                                          value: 0,
                                          target: habit.goalValue))
                    }
                } else {
                    data.append(.init(key: formatShortWeekday(date), value: 0, target: 0))
                }
            }
        case .month:
            let dates = Calendar.current.getDatesInMonth()
            for date in dates {
                if date.isDateValid(habit) {
                    if let record = records.first(where: { $0.date.isSameDay(date: date)}) {
                        data.append(.init(key: date.format("dd"),
                                          value: record.value,
                                          target: habit.goalValue))
                    } else {
                        data.append(.init(key: date.format("dd"),
                                          value: 0,
                                          target: habit.goalValue))
                    }
                } else {
                    data.append(.init(key: date.format("dd"),
                                      value: 0,
                                      target: 0))
                }
            }
            break
        case .year:
            for month in 1...12 {
                let dates = Calendar.current.getDatesInMonth(year: Date().year, month: month)
                var target: Double = 0
                
                for date in dates {
                    if date.isDateValid(habit) {
                        target += habit.goalValue
                    }
                }
                
                let currentValue = records.filter({ $0.date.isSameMonth(as: dates.first!)}).map({ $0.value }).reduce(0, +)
                data.append(.init(key: formatShortMonth(dates.first!),
                                  value: currentValue,
                                  target: target))
            }
        }
        
        return data
    }
    
    func formatShortWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "vi_VN")
            formatter.dateFormat = "EEE" // viết tắt thứ
            return formatter.string(from: date).capitalized
    }
    
    func formatShortMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN") // Đảm bảo ngôn ngữ tiếng Anh
        formatter.dateFormat = "MMM" // Lấy tháng rút gọn
        return formatter.string(from: date)
    }
}

// MARK: - ChartView
struct ChartView: View {
    let data: [ChartData]
    
    var body: some View {
        HStack(spacing: 0) {
            
            VStack(spacing: 0) {
                ForEach(moc, id: \.self) { index in
                    Text(index.text)
                        .gilroyRegular(10)
                        .frame(height: 16)
                    
                    if index != moc.last {
                        Spacer(minLength: 0)
                    }
                }
            }
            .offset(y: -8)
            .frame(width: 50)
            
            ForEach(data, id: \.key) { index in
                Spacer(minLength: 3)
                
                VStack(alignment: .center, spacing: 0) {
                    GeometryReader { proxy in
                        let width = proxy.size.width / 4
                        ZStack(alignment: .bottom) {
                            Color.clear
                            
                            RoundedRectangle(cornerRadius: width / 2)
                                .fill(.gray.opacity(0.3))
                                .frame(width: width,
                                       height: proxy.size.height / maxStep * index.target)
                            
                            RoundedRectangle(cornerRadius: width / 2)
                                .fill(.red)
                                .frame(width: width,
                                       height: proxy.size.height / maxStep * index.value)
                        }
                    }
                    
                    Text(index.key)
                        .gilroyRegular(10)
                        .autoresize(1)
                        .frame(height: 16)
                    
                }
            }
        }
        .background(
            VStack(spacing: 0) {
                ForEach(moc, id: \.self) { index in
                    Color.gray.opacity(0.1).frame(height: 1)
                    
                    if index != moc.last {
                        Spacer(minLength: 0)
                    }
                }
                
                
                Text("")
                    .gilroyRegular(10)
                    .frame(height: 16)
            }
        )
    }
    
    var moc: [Double] {
        return calculateYAxisSteps(from: data)
    }
    
    var maxStep: Double {
        moc.first ?? 1
    }
    
    func calculateYAxisSteps( from data: [ChartData], numberOfSteps: Int = 5) -> [Double] {
        let maxValue = data.flatMap { [$0.value, $0.target] }.max() ?? 0
        
        // Trường hợp không có dữ liệu > 0
        if maxValue == 0 {
            return (0...numberOfSteps).map { Double($0 * 5) }
        }
        
        // Tìm step sao cho step * numberOfSteps >= maxValue
        var step = ceil(maxValue / Double(numberOfSteps))
        
        // Làm tròn step về bội của 5
        step = ceil(step / 5) * 5
        
        return (0...numberOfSteps).map { Double($0) * step }.reversed()
    }
}

fileprivate struct TabItemView: View {
    var type: TimePeriod
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            isSelected ? Color("Black") : Color.clear
            
            Text("1 " + type.rawValue.capitalized)
                .gilroyMedium(9)
                .foregroundStyle(!isSelected ? Color("Gray") : Color("White"))
        }
        .frame(width: 50, height: 20)
        .cornerRadius(2)
    }
}


#Preview {
    HomeView(viewModel: .init())
}
