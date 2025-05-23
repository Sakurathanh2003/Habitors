//
//  SummaryView.swift
//  Habitors
//
//  Created by Thanh Vu on 24/4/25.
//
import SwiftUI

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
        
        func title(_ date: Date, isVietnamese: Bool) -> String {
            return switch self {
            case .bestStreak:
                isVietnamese ? "Kỷ lục chuỗi ngày" : "Best Streak"
            case .currentStreak:
                isVietnamese ? "Chuỗi liên tiếp hiện tại" : "Current Streak"
            case .doneInMonth:
                (isVietnamese ? "Hoàn thành trong " : "Done in ") + date.format("MMMM", isVietnamese: isVietnamese)
            case .totalDone:
                "Total Done"
            }
        }
        
        var image: String {
            switch self {
            case .bestStreak:
                "statistics_serial_all_Normal"
            case .currentStreak:
                "statistics_serial_now_Normal"
            case .doneInMonth:
                "statistics_day_month_Normal"
            case .totalDone:
                "statistics_day_all_Normal"
            }
        }
    }
    
    @ObservedObject var viewModel: HomeViewModel
    
    var value: Int
    var type: SummaryType
    
    var color: Color {
        switch type {
        case .bestStreak:
            Color("good")
        case .currentStreak:
            Color("upset")
        case .doneInMonth:
            Color("Information")
        case .totalDone:
            Color("Success")
        }
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(type.image)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(color)
                            .frame(width: 20)
                    )
                    .padding(.bottom, 20)
                
                Spacer()
            }
            
            let unitString = viewModel.translate("\(type.unit)")
            Text("\(value)").fontBold(16)
            + Text(" \(unitString)").fontRegular(10)
               
            Text(viewModel.translate(type.title(viewModel.currentMonth, isVietnamese: viewModel.isVietnameseLanguage)))
                .fontRegular(10)
                .padding(.top, 3)
        }
        .padding(10)
        .background(.white)
        .cornerRadius(5)
    }
}

#Preview {
    HomeView(viewModel: .init())
}
