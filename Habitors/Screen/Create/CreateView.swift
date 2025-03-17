//
//  CreateView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import SwiftUI
import RxSwift

fileprivate struct Const {
    static let horizontalPadding: CGFloat = 24
    
    static let itemSpacing: CGFloat = 12
    static let itemWidth = (UIScreen.main.bounds.width - itemSpacing * 6 - horizontalPadding * 2) / 7
    static let itemCorner = itemWidth / 36 * 8
    static let itemTextSize = itemWidth / 36 * 14
}

struct CreateView: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    thumbnailView
                    nameField
                    dateAndPeriodView
                    repeatView
                    reminderView
                }
                .padding(.bottom, 100)
            }
        }
        .padding(.horizontal, Const.horizontalPadding)
        .overlay(
            ZStack {
                if viewModel.isShowingCalendar {
                    CalendarDialog(selectedDate: viewModel.selectedDate, cancelAction: {
                        withAnimation {
                            viewModel.isShowingCalendar = false
                        }
                    }, doneAction: { selectedDates in
                        viewModel.selectedDate = selectedDates
                        withAnimation {
                            viewModel.isShowingCalendar = false
                        }
                    })
                }
                
                if viewModel.isShowingPeriodDialog {
                    SetPeriodDialog(isMorning: viewModel.isMorning, isEvening: viewModel.isEvening, cancelAction: {
                        withAnimation {
                            viewModel.isShowingPeriodDialog = false
                        }
                    }, doneAction: { isMorning, isEvening in
                        viewModel.isMorning = isMorning
                        viewModel.isEvening = isEvening
                        
                        withAnimation {
                            viewModel.isShowingPeriodDialog = false
                        }
                    })
                }
            }
        )
    }
    
    // MARK: - Reminder
    @ViewBuilder
    var reminderView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Get reminders")
                    .gilroySemiBold(18)
                    .foregroundStyle(Color("Black"))
                
                Spacer()
                
                HabitToggle(isOn: $viewModel.isTurnOnReminder)
            }
            .frame(height: 29)
            
            HStack(alignment: .top) {
                HStack {
                    Image("ic_timer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    
                    Text("Morning Period")
                        .gilroySemiBold(14)
                        .foregroundStyle(Color("Black"))
                }
                
                Spacer(minLength: 0)
                
                VStack(spacing: 12) {
                    Text("10:00 AM")
                        .gilroySemiBold(14)
                        .foregroundStyle(Color("Gray"))
                    
                    Text("11:00 AM")
                        .gilroySemiBold(14)
                        .foregroundStyle(Color("Gray"))
                }
            }
            
            HStack {
                Spacer()
                Text("+ Add more")
                    .gilroySemiBold(14)
                    .foregroundStyle(.white)
                    .frame(height: 24)
                    .padding(8)
                    .background(Color("Primary"))
                    .cornerRadius(6)
            }
        }
    }
    
    // MARK: - Repeat
    @ViewBuilder
    var repeatView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Repeat everyday")
                    .gilroySemiBold(18)
                    .foregroundStyle(Color("Black"))
                
                Spacer()
                
                Circle()
                    .fill(Color("Success"))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "checkmark")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8)
                            .foregroundStyle(.white)
                    )
            }
            .frame(height: 29)
            
            HStack(spacing: 0) {
                let dates = ["M", "T", "W", "T", "F", "S", "S"]
                ForEach(0..<dates.count, id: \.self) { index in
                    ZStack {
                        if viewModel.didSelectedRepeatDay(index) {
                            RoundedRectangle(cornerRadius: Const.itemCorner)
                                .fill(Color("Primary"))
                                .frame(width: Const.itemWidth, height: Const.itemWidth)
                                .overlay(
                                    Text(dates[index])
                                        .gilroySemiBold(Const.itemTextSize)
                                        .foregroundStyle(.white)
                                )
                                
                        } else {
                            RoundedRectangle(cornerRadius: Const.itemCorner)
                                .stroke(Color("Gray"), lineWidth: 1)
                                .frame(width: Const.itemWidth, height: Const.itemWidth)
                                .overlay(
                                    Text(dates[index])
                                        .gilroySemiBold(Const.itemTextSize)
                                        .foregroundStyle(Color("Gray"))
                                )
                        }
                    }
                    .onTapGesture {
                        viewModel.input.selectRepeatDay.onNext(index)
                    }
                    
                    if index != dates.count - 1 {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }
    
    // MARK: - Habit date and period
    @ViewBuilder
    var dateAndPeriodView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Set Habit date & Period")
                    .gilroySemiBold(18)
                    .foregroundStyle(Color("Black"))
                
                Spacer()
                
                Circle()
                    .fill(Color("Success"))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "checkmark")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8)
                            .foregroundStyle(.white)
                    )
            }
            .frame(height: 29)
            
            
            HStack(spacing: 9) {
                HStack {
                    Image("ic_calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .padding(14)
                        .background(Color("F0EFFB"))
                        .cornerRadius(26)
                    
                    Text(viewModel.selectedDate.isEmpty ? "+ Add date" : viewModel.descriptionOfHabitDate)
                        .gilroyMedium(14)
                        .foregroundStyle(Color("6C5DD3"))
                }
                .onTapGesture {
                    withAnimation {
                        viewModel.isShowingCalendar = true
                    }
                }
                
                Spacer(minLength: 0)
                
                HStack {
                    Image("ic_star")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .padding(14)
                        .background(Color("F5FBEF"))
                        .cornerRadius(26)
                    
                    if !viewModel.isMorning && !viewModel.isEvening {
                        Text("+ Add Period")
                            .gilroyMedium(14)
                            .foregroundStyle(Color("619D14"))
                    } else {
                        VStack {
                            if viewModel.isMorning {
                                Text("Morning")
                                    .gilroyMedium(14)
                                    .foregroundStyle(Color("619D14"))
                            }
                            
                            if viewModel.isEvening {
                                Text("Evening")
                                    .gilroyMedium(14)
                                    .foregroundStyle(Color("619D14"))
                            }
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                .onTapGesture {
                    withAnimation {
                        viewModel.isShowingPeriodDialog = true
                    }
                }
            }
        }
    }
    
    // MARK: - Name
    @ViewBuilder
    var nameField: some View {
        VStack(alignment: .leading) {
            Text("Name")
                .gilroySemiBold(18)
                .foregroundStyle(Color("Gray"))
            
            TextField(text: $viewModel.name) {
                Text("Enter your habit name")
            }
            .gilroyMedium(16)
            .foregroundColor(Color("Black"))
            .frame(height: 56)
            .padding(.leading, 16)
            .background(Color("Gray01"))
            .cornerRadius(12)
        }
    }
    
    
    
    // MARK: - Thumbnail
    var thumbnailView: some View {
        ZStack {
            HStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.red)
                    .frame(width: 96, height: 96)
                    .padding(2)
                    .blur(radius: 2)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(.blue)
                    .frame(width: 96, height: 96)
                    .padding(2)
                    .blur(radius: 2)
            }
            
            RoundedRectangle(cornerRadius: 20)
                .fill(.black)
                .frame(width: 112, height: 112)
        }
    }
    
    var navigationBar: some View {
        HStack {
            Image("ic_back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            Spacer(minLength: 0)
            
            Button {
                
            } label: {
                Text("Save")
                    .gilroyBold(18)
                    .foregroundStyle(Color("Primary"))
            }
        }
        .frame(height: 56)
        .overlay(
            Text("New Habit")
                .gilroyBold(20)
                .foregroundStyle(Color("Black"))
        )
    }
    
   
}

#Preview {
    CreateView(viewModel: .init())
}
