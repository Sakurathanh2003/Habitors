//
//  CalendarDialog.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import SwiftUI

fileprivate struct Const {
    static let horizontalPadding: CGFloat = 40
    
    static let itemSpacing: CGFloat = 12
    static let itemWidth = (UIScreen.main.bounds.width - itemSpacing * 6 - horizontalPadding * 2) / 7
}

struct CalendarDialog: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var days = [
        "M", "T", "W", "T", "F", "S", "S"
    ]
    
    var cancelAction: (() -> Void)
    var doneAction: (([Date]) -> Void)
    
    init(selectedDate: [Date], cancelAction: @escaping () -> Void, doneAction: @escaping ([Date]) -> Void) {
        self.viewModel = CalendarViewModel(selectedDate: selectedDate)
        self.cancelAction = cancelAction
        self.doneAction = doneAction
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
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
                    Text(viewModel.month)
                        .gilroySemiBold(18)
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
                            .gilroyBold(14)
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
                        if viewModel.isSameMonth(date) {
                            Button {
                                viewModel.chooseDay(date)
                            } label: {
                                Text("\(date.day)")
                                    .gilroyRegular(14)
                                    .frame(width: Const.itemWidth, height: Const.itemWidth)
                                    .background(viewModel.isSelected(date) ? Color("Primary") : Color.clear)
                                    .foregroundColor(viewModel.isSelected(date) ? .white : .black)
                                    .cornerRadius(8)
                            }
                        } else {
                            Text("\(date.day)")
                                .gilroyRegular(14)
                                .frame(width: Const.itemWidth, height: Const.itemWidth)
                                .foregroundColor(Color("CBD5E0"))
                        }
                    }
                }
                
                HStack(spacing: 20) {
                    Spacer()
                    
                    Button(action: {
                        cancelAction()
                    }, label: {
                        Text("Cancel")
                            .gilroyMedium(14)
                            .foregroundStyle(Color("Black"))
                    })
                    
                    Button(action: {
                        doneAction(viewModel.selectedDate)
                    }, label: {
                        Text("Done")
                            .gilroyMedium(14)
                            .foregroundStyle(Color("Primary"))
                    })
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 24)
            .background(.white)
            .cornerRadius(12)
            .padding(24)
        }
    }
}

#Preview {
    CalendarDialog(selectedDate: [], cancelAction: {
        
    }, doneAction: { dates in
        
    })
}
