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

struct HomeActivityView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var currentTab = TimePeriod.week
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
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
                .cornerRadius(12)
                .padding(.horizontal, Const.horizontalPadding)
                
                chartView
                    .padding(.top, 25)
                    .padding(.horizontal, Const.horizontalPadding)
               
                    
                Color("Gray")
                    .frame(height: 1)
                    .padding(.top, 16)
                    .padding(.horizontal, Const.horizontalPadding)
                
                summaryView
                    .padding(.horizontal, Const.horizontalPadding)
               
                   
                Color("Gray")
                    .frame(height: 1)
                    .padding(.top, 16)
                    .padding(.horizontal, Const.horizontalPadding)
                
                VStack(spacing: 24) {
                    todayGoalView
                        .padding(.top, 13)
                    
                    weekGoalView
                }
                
                Spacer()
            }
            .padding(.bottom, 100)
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
    
    var summaryView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your weekly records of doing the task")
                .gilroySemiBold(18)
                .foregroundStyle(Color("Black"))
            
            HStack {
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 9) {
                        Circle()
                            .fill(Color("Gray02"))
                            .frame(width: 16, height: 16)
                        
                        Text("Average weekly record")
                            .gilroyMedium(12)
                            .foregroundStyle(Color("Gray"))
                    }
                   
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color("Primary"))
                            .frame(width: 16, height: 16)
                        
                        Text("Today records")
                            .gilroyMedium(12)
                            .foregroundStyle(Color("Gray"))
                    }
                    
                    
                }
                
                Spacer(minLength: 0)
                
                ProgressCircle(progress: 0.5)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text("50%")
                            .gilroyBold(20)
                            .foregroundStyle(Color("Black"))
                    )
            }
        }.padding(.top, 24)
    }
    
    @State var dayInWeek = [
        "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
    ]
    
    @State var percents = [
        "100%", "80%", "60%", "40%", "20%"
    ]
    
    @State var data: [CGFloat] = [
        0, 50, 0, 50, 0, 20, 0
    ]
    
    func line(bounds: CGSize) -> Path {
        let width = bounds.width
        let height = bounds.height
        
        let itemWidth = Const.dayTextWidth
        let itemSpacing = (width - itemWidth * 7) / 6
        
        return Path { path in
            func coordYFor(index: Int) -> CGFloat {
                return height - height * data[index] / 100 + Const.percentTextHeight / 2
            }
            
            func coordXFor(index: Int) -> CGFloat {
                return itemWidth / 2 + (itemSpacing + itemWidth) * CGFloat(index)
            }
            
            var p1 = CGPoint(x: itemWidth / 2,
                             y: coordYFor(index: 0))
            path.move(to: p1)
            
            var oldControlP: CGPoint?
            
            for index in 1..<7 {
                
                let p2 = CGPoint(x: coordXFor(index: index),
                                 y: coordYFor(index: index))
                
                var p3: CGPoint?
                
                if index < data.count - 1 {
                    p3 = CGPoint(x: itemWidth / 2 + (itemSpacing + itemWidth) * CGFloat(index + 1),
                                 y: height - height * data[index + 1] / 100 + Const.percentTextHeight / 2)
                }
                
                let newControlP = controlPointForPoints(p1: p1, p2: p2, next: p3)
                
                path.addCurve(to: p2, control1: oldControlP ?? p1, control2: newControlP ?? p2)
                
                p1 = p2
                oldControlP = antipodalFor(point: newControlP, center: p2)
            }
        }
    }
    
    @ViewBuilder
    var chartView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                VStack {
                    ForEach(percents, id: \.self) { percent in
                        DashedLineView(color: Color("Gray02"), lineHeight: 0.5)
                            .frame(height: 14)
                        Spacer()
                    }
                }
                .clipped()
                .overlay(
                    GeometryReader(content: { proxy in
                        ZStack {
                            line(bounds: proxy.size)
                                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round)) // Độ dài nét & khoảng cách
                                .foregroundColor(Color("Primary")) // Màu của đường line
                            
                            line(bounds: proxy.size)
                                .fill(
                                    LinearGradient(colors: [
                                        Color("Primary").opacity(0.7),
                                        Color("Primary").opacity(0.7),
                                        Color("Primary").opacity(0.7),
                                        Color("Primary").opacity(0)
                                    ], startPoint: .top, endPoint: .bottom)
                                )
                        }
                    })
                )
                
                VStack {
                    ForEach(percents, id: \.self) { percent in
                        Text(percent)
                            .gilroyMedium(12)
                            .foregroundStyle(Color("Gray"))
                            .frame(height: 14)
                        
                        Spacer()
                    }
                }
                .frame(width: 30)
            }
            
            DashedLineView(color: Color("Gray02"), lineHeight: 0.5)
            
            HStack(spacing: 0) {
                ForEach(dayInWeek.indices, id: \.self) { index in
                    Text(dayInWeek[index])
                        .gilroyMedium(12)
                        .foregroundStyle(Color("Gray"))
                        .frame(width: Const.dayTextWidth)
                    
                    if index != dayInWeek.count - 1 {
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.trailing, 30)
        }
        .frame(height: (UIScreen.main.bounds.width - Const.horizontalPadding * 2) / 329 * 229)
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

fileprivate struct TabItemView: View {
    var type: TimePeriod
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            isSelected ? Color("Black") : Color.clear
            
            Text(type.rawValue.capitalized)
                .gilroyMedium(14)
                .foregroundStyle(!isSelected ? Color("Gray") : Color("White"))
        }
        .frame(height: 40)
        .cornerRadius(8)
    }
}

#Preview {
    HomeView(viewModel: .init())
}
