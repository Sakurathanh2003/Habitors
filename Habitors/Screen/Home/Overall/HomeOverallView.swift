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

// MARK: - HomeOverallView
struct HomeOverallView: View {
    @ObservedObject var viewModel: HomeViewModel
    
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
                            viewModel.input.overallHabit.onNext(nil)
                        }
                    
                    ForEach(viewModel.allHabit, id: \.id) { habit in
                        thumbnailHabitView(habit: habit)
                        .onTapGesture {
                            viewModel.input.overallHabit.onNext(habit)
                        }
                    }
                    
                }.padding(.horizontal, 20)
            }
            .frame(height: 50)
            .background(
                ZStack {
                    if User.isTurnDarkMode {
                        Color.black
                    } else {
                        Color.white
                    }
                }
            )
            .zIndex(1)
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 20) {
                    Color.clear.frame(height: 1)
                    HomeCalendarView(viewModel: viewModel)
                        .padding(20)
                        .background(.white)
                        .cornerRadius(5)
                        .padding(.horizontal, 20)
                    
                    if let currentHabit = viewModel.currentHabit {
                        YearStatusView(viewModel: viewModel, records: currentHabit.records)
                        
                        LazyVGrid(columns: [.init(), .init()]) {
                            SummaryView(viewModel: viewModel,
                                        value: viewModel.doneInMonth,
                                        type: .doneInMonth)
                            SummaryView(viewModel: viewModel,
                                        value: viewModel.totalDoneDate.count,
                                        type: .totalDone)
                            SummaryView(viewModel: viewModel,
                                        value: viewModel.currentStreak,
                                        type: .currentStreak)
                            SummaryView(viewModel: viewModel,
                                        value: viewModel.bestStreak,
                                        type: .bestStreak)
                        }
                        .padding(.horizontal, 20)
                        
                        TrendingView(viewModel: viewModel,
                                     records: currentHabit.records,
                                     habit: currentHabit)
                    } else {
                        LazyVGrid(columns: [.init(), .init()]) {
                            SummaryView(viewModel: viewModel,
                                        value: viewModel.doneInMonth,
                                        type: .doneInMonth)
                            SummaryView(viewModel: viewModel,
                                        value: viewModel.totalDoneDate.count,
                                        type: .totalDone)
                            SummaryView(viewModel: viewModel,
                                        value: viewModel.currentStreak,
                                        type: .currentStreak)
                            SummaryView(viewModel: viewModel,
                                        value: viewModel.bestStreak,
                                        type: .bestStreak)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, UIScreen.main.bounds.height / 2)
            }
            .background(Color.gray.opacity(0.1))
        }
    }
    
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
}

#Preview {
    HomeView(viewModel: .init())
}
