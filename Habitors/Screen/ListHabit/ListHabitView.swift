//
//  ListHabitView.swift
//  Habitors
//
//  Created by Thanh Vu on 6/5/25.
//

import SwiftUI
import RxSwift
import SakuraExtension

struct ListHabitView: View {
    @ObservedObject var viewModel: ListHabitViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if viewModel.isSelectMode {
                    Button {
                        viewModel.isSelectMode = false
                        viewModel.selectedHabit = []
                    } label: {
                        Text(viewModel.isVietnameseLanguage ? "Huỷ" : "Cancel")
                            .fontSemiBold(16)
                            .foreColor(viewModel.mainColor)
                    }
                } else {
                    Button {
                        withAnimation {
                            viewModel.routing.stop.onNext(())
                        }
                    } label: {
                        Image("ic_back")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foreColor(viewModel.mainColor)
                    }
                }
                
                Spacer()
                
                if !viewModel.habits.isEmpty {
                    Button {
                        if viewModel.isSelectMode {
                            viewModel.input.didTapDelete.onNext(())
                        } else {
                            viewModel.isSelectMode = true
                        }
                    } label: {
                        Text(viewModel.isSelectMode
                             ? viewModel.isVietnameseLanguage ? "Xoá" : "Delete"
                             : viewModel.isVietnameseLanguage ? "Chọn" : "Select"
                        )
                        .fontSemiBold(16)
                        .foreColor(viewModel.isSelectMode ? Color("Error") : viewModel.mainColor)
                    }
                }
            }
            .overlay(
                Text(viewModel.isVietnameseLanguage ? "Danh sách thói quen" : "List Habit")
                    .fontBold(18)
                    .autoresize(1)
                    .foreColor(viewModel.mainColor)
            )
            .frame(height: 56)
            .padding(.horizontal, 20)
            
            if viewModel.habits.isEmpty {
                Image("ic_empty")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
                    .padding(.top, 20)
                
                Text(viewModel.isVietnameseLanguage ? "Bạn không có thói quen nào cả" : "You don't have any habits")
                    .fontRegular(16)
                    .padding(.top, 20)
                    .foreColor(.gray)
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [.init()], spacing: 20) {
                        ForEach(viewModel.habits, id: \.id) { habit in
                            HabitItemView(viewModel: viewModel, habit: habit)
                                .onTapGesture {
                                    viewModel.input.selectHabit.onNext(habit)
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
    @ObservedObject var viewModel: ListHabitViewModel
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
            
            if viewModel.isSelectMode {
                if viewModel.isSelected(habit: habit) {
                    Image(systemName: "checkmark.circle.fill")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                        .foreColor(Color("Primary"))
                } else {
                    Circle()
                        .stroke(lineWidth: 1)
                        .frame(width: 20)
                }
            } else {
                Image("ic_arrow_right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
            }
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
