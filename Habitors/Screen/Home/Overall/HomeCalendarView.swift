//
//  CalendarView.swift
//  Habitors
//
//  Created by Thanh Vu on 24/4/25.
//
import SwiftUI
import RxSwift

fileprivate struct Const {
    static let horizontalPadding: CGFloat = 40
    
    static let itemSpacing: CGFloat = 12
    static let itemWidth = (UIScreen.main.bounds.width - itemSpacing * 6 - horizontalPadding * 2) / 7
}

struct HomeCalendarView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var days = [
        "M", "T", "W", "T", "F", "S", "S"
    ]
        
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    viewModel.updatePreviousMonth()
                } label: {
                    Image("ic_arrow_left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                
                Spacer()
                Text(month)
                    .fontSemiBold(18)
                    .foregroundStyle(Color("Black"))
                
                Spacer()
                
                Button {
                    viewModel.updateNextMonth()
                } label: {
                    Image("ic_arrow_right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }.frame(height: 28)
            
            HStack {
                ForEach(days.indices, id: \.self) { index in
                    Text(days[index])
                        .fontBold(14)
                        .foregroundStyle(Color("Primary"))
                        .frame(width: Const.itemWidth, height: Const.itemWidth)
                    
                    if index != days.count - 1 {
                        Spacer()
                    }
                }
            }
            .padding(.top, 16)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(viewModel.daysInMonth, id: \.self) { date in
                    let percent = viewModel.percentInDate(date)
                    let hasHabit = viewModel.hasHabit(in: date)
                    
                    Text("\(date.day)")
                        .fontRegular(14)
                        .frame(width: Const.itemWidth, height: Const.itemWidth)
                        .foregroundColor(.black)
                        .overlay(
                            ZStack {
                                if hasHabit {
                                    Circle()
                                        .stroke(Color("Gray"), lineWidth: 2)
                                        .padding(4)
                                        .opacity(0.2)
                                }
                                
                                Circle()
                                    .trim(from: 0, to: percent)
                                    .stroke(Color(rgb: 0x67D9FB),lineWidth: 2)
                                    .padding(4)
                                    .rotationEffect(.degrees(-90))
                                    .overlay(
                                        GeometryReader(content: { proxy in
                                            Image("king")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10, height: 10)
                                                .offset(
                                                    x: proxy.size.width / 2 ,
                                                    y: -proxy.size.height / 2
                                                )
                                                .rotationEffect(.degrees(42))
                                                .opacity(percent >= 1 ? 1 : 0)
                                        })
                                    )
                            }
                        )
                        .cornerRadius(8)
                        .opacity(date.isSameMonth(as: viewModel.currentMonth) ? 1 : 0.3)
                }
            }
        }
    }
}

// MARK: - Get
extension HomeCalendarView {
    var month: String {
        return viewModel.currentMonth.format("MMMM yyyy", isVietnamese: User.isVietnamese).capitalized
    }
}
