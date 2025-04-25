//
//  TrendingView.swift
//  Habitors
//
//  Created by Thanh Vu on 24/4/25.
//
import SwiftUI

struct ChartData {
    var key: String
    var value: Double
    var target: Double
}

// MARK: - Trending
struct TrendingView: View {
    @State var currentTab = TimePeriod.week
    var records: [HabitRecord]
    var habit: Habit
    let date = Date()
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text("Trending").fontBold(16)
                
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

fileprivate struct TabItemView: View {
    var type: TimePeriod
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            isSelected ? Color("Black") : Color.clear
            
            Text("1 " + type.rawValue.capitalized)
                .fontMedium(9)
                .foregroundStyle(!isSelected ? Color("Gray") : Color("White"))
        }
        .frame(width: 50, height: 20)
        .cornerRadius(2)
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
                        .fontRegular(10)
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
                        .fontRegular(10)
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
                    .fontRegular(10)
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

#Preview {
    HomeView(viewModel: .init())
}
