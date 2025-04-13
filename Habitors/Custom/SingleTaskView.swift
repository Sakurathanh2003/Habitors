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
                    .gilroySemiBold(16)
                    .foregroundStyle(Color("Black"))
                
                if isCompleted {
                    Text("Đã hoàn thành")
                        .gilroyMedium(12)
                        .foregroundStyle(Color("Success"))
                } else {
                    Text(description)
                        .gilroyMedium(12)
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
        switch habit.goalUnit {
        case .min, .hours, .secs:
            let hours = Int(baseGoalDayValue) / 3600       // Calculate hours
            let minutes = (Int(baseGoalDayValue) % 3600) / 60  // Calculate minutes
            let seconds = Int(baseGoalDayValue) % 60        // Calculate seconds
            var timeComponents = [String]()

            if hours > 0 {
                timeComponents.append("\(hours) giờ")
            }

            if minutes > 0 {
                timeComponents.append("\(minutes) phút")
            }

            if seconds > 0 {
                timeComponents.append("\(seconds) giây")
            }

            let time = timeComponents.joined(separator: " ")
            return "Còn \(time) nữa là hoàn thành"
        default:
            return "Còn \(unit.convertToUnit(from: baseGoalDayValue).text) \(unit.description) nữa là hoàn thành"
        }
    }
}
