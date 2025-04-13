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
    var note: String
    var unit: String
    var value: Double
    
    var color: Color
    var imageName: String
    
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
            
            Text(value.text)
                .gilroyBold(16)
            + Text(" \(unit)")
                .gilroyRegular(10)
               
            
            Text(note)
                .gilroyRegular(10)
                .padding(.top, 3)
        }
        .padding(10)
        .background(.white)
        .cornerRadius(5)
    }
}

struct HomeActivityView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var currentTab = TimePeriod.week
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {
                Color.clear.frame(height: 1)
                calendarView
                statusView
                summaryView
                trendingView
                comparationView
            }
            .padding(.bottom, 100)
        }
        .background(Color.black)
    }
    
    // MARK: - Summary View
    var summaryView: some View {
        LazyVGrid(columns: [.init(), .init()]) {
            SummaryView(note: "Done in May",
                        unit: "Day",
                        value: 100,
                        color: .red,
                        imageName: "")
            SummaryView(note: "Total Done",
                        unit: "Day",
                        value: 100,
                        color: .red,
                        imageName: "")
            SummaryView(note: "Current Streak",
                        unit: "Day",
                        value: 100,
                        color: .red,
                        imageName: "")
            SummaryView(note: "Best Streak",
                        unit: "Day",
                        value: 100,
                        color: .red,
                        imageName: "")
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Status
    @ViewBuilder
    var statusView: some View {
        let width = UIScreen.main.bounds.width - 80
        let spacing = 1.0
        let itemWidth = (width - spacing * 51) / 52
        
        VStack(spacing: 10) {
            HStack {
                Text("Yearly status").gilroySemiBold(14)
                Spacer()
                
                HStack(spacing: 2) {
                    Text("2025").gilroyRegular(10)
                    Image(systemName: "chevron.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 5, height: 5)
                }
                .padding(5)
                .background(Color("Gray02"))
                .cornerRadius(5)
            }
            
            VStack(spacing: spacing) {
                ForEach(1...7, id: \.self) { _ in
                    HStack(spacing: spacing) {
                        ForEach(1...52, id: \.self) { _ in
                            RoundedRectangle(cornerSize: .zero)
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
    
    // MARK: - Calendar View
    var calendarView: some View {
        CalendarView(viewModel: CalendarViewModel(mode: .analytic))
            .padding(20)
            .background(.white)
            .cornerRadius(5)
            .padding(.horizontal, 20)
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
    
    @ViewBuilder
    var todayGoalView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Today's goal")
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
    
   
    
    @ViewBuilder
    var trendingView: some View {
        let data: [ChartData] = [
            .init(key: "1", value: 25, target: 1000),
            .init(key: "2", value: 50, target: 2240),
            .init(key: "3", value: 2000, target: 2200),
            .init(key: "4", value: 100, target: 1000),
            .init(key: "5", value: 125, target: 1000),
            .init(key: "6", value: 90, target: 1000),
            .init(key: "7", value: 10, target: 1000),
            .init(key: "8", value: 1000, target: 1000),
        ]
        
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
    
    @ViewBuilder
    var comparationView: some View {
        let data: [ChartData] = [
            .init(key: "1", value: 25, target: 1000),
            .init(key: "2", value: 50, target: 2240),
            .init(key: "3", value: 2000, target: 2200),
            .init(key: "4", value: 100, target: 1000),
            .init(key: "5", value: 125, target: 1000),
            .init(key: "6", value: 90, target: 1000),
            .init(key: "7", value: 10, target: 1000),
            .init(key: "8", value: 1000, target: 1000),
        ]
        
        VStack(spacing: 30) {
            HStack {
                Text("Comparision").gilroyBold(16)
                
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
    
    func midPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
    func controlPointForPoints(p1: CGPoint, p2: CGPoint, next p3: CGPoint?) -> CGPoint? {
        guard let p3 = p3 else {
            return nil
        }
        
        let leftMidPoint  = midPointForPoints(p1: p1, p2: p2)
        let rightMidPoint = midPointForPoints(p1: p2, p2: p3)
        
        var controlPoint = midPointForPoints(p1: leftMidPoint, p2: antipodalFor(point: rightMidPoint, center: p2)!)
        
        controlPoint.x += (p2.x - p1.x) * 0.1
        
        return controlPoint
    }
    
    func antipodalFor(point: CGPoint?, center: CGPoint?) -> CGPoint? {
        guard let p1 = point, let center = center else {
            return nil
        }
        let newX = 2 * center.x - p1.x
        let diffY = abs(p1.y - center.y)
        let newY = center.y + diffY * (p1.y < center.y ? 1 : -1)
        
        return CGPoint(x: newX, y: newY)
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
                Spacer(minLength: 0)
                
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
