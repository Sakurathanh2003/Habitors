//
//  ListHabitView.swift
//  Habitors
//
//  Created by Thanh Vu on 6/5/25.
//

import SwiftUI
import RxSwift

struct ListHabitView: View {
    @ObservedObject var viewModel: ListHabitViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationBarView(title: "List Habit", isDarkMode: viewModel.isTurnDarkMode) {
                viewModel.routing.stop.onNext(())
            }.padding(.horizontal, 20)
            
            if viewModel.habits.isEmpty {
                Image("ic_empty")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
                    .padding(.top, 20)
                
                Text("You don't have any habits")
                    .fontRegular(16)
                    .padding(.top, 20)
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [.init()], spacing: 20) {
                        ForEach(viewModel.habits, id: \.id) { habit in
                            HabitItemView(habit: habit)
                                .onTapGesture {
                                    viewModel.routing.routeToHabit.onNext(habit)
                                }
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(viewModel.backgroundColor.ignoresSafeArea())
    }
}

// MARK: - HabitItemView
fileprivate struct HabitItemView: View {
    var habit: Habit
    
    @ViewBuilder
    var iconThumbnail: some View {
        if habit.icon.count == 1 {
            Text(habit.icon)
                .font(.system(size: 40))
        } else {
            Image(habit.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(2)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 4)
                .fill(.white)
                .frame(width: 59, height: 59)
                .overlay(iconThumbnail)
            
            Text(habit.name)
                .fontSemiBold(16)
                .foregroundStyle(Color("Black"))
            
            Spacer(minLength: 0)
            
            Image("ic_arrow_right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 81)
        .background(Color("Gray01"))
        .cornerRadius(12)
    }
    
    var repeatType: Frequency.RepeatType {
        return habit.frequency.type
    }
    
    var goalValue: Double {
        return habit.goalValue
    }
    
    var unit: GoalUnit {
        return habit.goalUnit
    }
}


#Preview {
    ListHabitView(viewModel: .init())
}
