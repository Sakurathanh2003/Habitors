//
//  YearStatusView.swift
//  Habitors
//
//  Created by Thanh Vu on 24/4/25.
//
import RxSwift
import SwiftUI

struct YearStatusView: View {
    @ObservedObject var viewModel: HomeViewModel
    var records: [HabitRecord]
    
    var body: some View {
        let width = UIScreen.main.bounds.width - 80
        let spacing = 1.0
        let itemWidth = (width - spacing * (numberOfWeek - 1)) / numberOfWeek
        
        VStack(spacing: 10) {
            HStack {
                Text("Yearly status").fontSemiBold(14)
                Spacer()
                
                HStack(spacing: 2) {
                    Image("ic_arrow_left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .onTapGesture {
                            viewModel.updatePreviousYear()
                        }
                    
                    Text(viewModel.currentYear.year.format("%d")).fontRegular(10)
                    
                    Image("ic_arrow_right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .onTapGesture {
                            viewModel.updateNextYear()
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
                            let date = viewModel.dateInYear[weekIndex * 7 + dayIndex]
                            
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
        
        if date.year != viewModel.currentYear.year {
            RoundedRectangle(cornerSize: .zero)
                .fill(.clear)
        } else {
            RoundedRectangle(cornerSize: .zero)
                .fill(Color("Primary").opacity(completedPercent))
                .background(Color("Gray02"))
        }
    }
}

// MARK: - Get
extension YearStatusView {
    var numberOfWeek: CGFloat {
        return CGFloat(viewModel.dateInYear.count / 7)
    }
}

#Preview {
    HomeView(viewModel: .init())
}
