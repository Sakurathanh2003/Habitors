//
//  SingleTaskView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import SwiftUI

struct SingleTaskView: View {
    var date: Date
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
            
            VStack(alignment: .leading, spacing: 10) {
                Text(habit.name)
                    .fontSemiBold(16)
                    .foregroundStyle(Color("Black"))
                
                if isCompleted {
                    Text(Translator.translate(key: "Completed"))
                        .fontMedium(12)
                        .foregroundStyle(Color("Success"))
                } else {
                    Text(description)
                        .fontMedium(12)
                        .foregroundStyle(Color("Gray"))
                }
            }
            
            Spacer(minLength: 0)
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
    
    var baseGoalDayValue: Double {
        unit.convertToBaseUnit(from: goalValue) - (record?.value ?? 0)
    }
    
    var record: HabitRecord? {
        habit.records.first(where: { $0.date.isSameDay(date: date )})
    }
    
    var isCompleted: Bool {
        baseGoalDayValue <= 0
    }
    
    var description: String {
        let percent: Double = min(1.0 - unit.convertToUnit(from: baseGoalDayValue) / goalValue, 1.0)
        return User.isVietnamese ? "Bạn đã thực hiện \((percent * 100).textWithDecimal(2))%" : "You have done \((percent * 100).textWithDecimal(2))%"
    }
}
