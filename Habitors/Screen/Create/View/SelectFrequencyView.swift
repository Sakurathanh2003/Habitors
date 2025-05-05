//
//  FrequencyView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 21/3/25.
//

import Foundation
import SwiftUI
import SakuraExtension

struct SelectFrequencyView: View {
    @State var type: Frequency.RepeatType = .daily
    @State var daily: Frequency.Daily = .init(selectedDays: [2, 3, 4, 5, 6, 7, 8])
    @State var weekly: Frequency.Weekly = .init(frequency: 1)
    @State var monthly: Frequency.Monthly = .init(type: .beginning)
    
    @State var times = [Time]()
    @State var isShowingTimeDialog: Bool = false
    @State var editTimeIndex: Int? = nil
    
    @State var didAppear: Bool = false
    @State var editingTime: Time?
    var cancelAction: (() -> Void)
    var doneAction: ((Frequency) -> Void)
    
    init(frequency: Frequency, cancelAction: @escaping () -> Void, doneAction: @escaping (Frequency) -> Void) {
        self.type = frequency.type
        self.daily = frequency.daily
        self.weekly = frequency.weekly
        self.monthly = frequency.monthly
        self.cancelAction = cancelAction
        self.doneAction = doneAction
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        Text("Frequency")
                            .fontBold(28)
                            .foreColor(mainColor)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                didAppear = false
                                cancelAction()
                            }
                        } label: {
                            Image("ic_x")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .foreColor(mainColor)
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 46)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            repeatSection
                            
                            switch type {
                            case .daily:
                                sectionTitle("On These Days")
                                    .padding(.top, 20)
                                HStack(spacing: 5) {
                                    let dates = ["M", "T", "W", "T", "F", "S", "S"]
                                    ForEach(0..<dates.count, id: \.self) { index in
                                        let isSelected = isSelectedDay(index)
                                        let selectedColor: Color = User.isTurnDarkMode ? .white : .black
                                        let unselectedColor: Color =  User.isTurnDarkMode ? Color("Black") : Color("Gray02")
                                        Circle()
                                            .fill(isSelected ? selectedColor : unselectedColor)
                                            .overlay(
                                                Text(dates[index])
                                                    .fontBold(16)
                                                    .foregroundStyle(
                                                        isSelected ? User.isTurnDarkMode ? .black : .white : !User.isTurnDarkMode ? .black : .white
                                                    )
                                            )
                                            .onTapGesture {
                                                if isSelected {
                                                    let selectedDays = daily.selectedDays
                                                    self.daily = .init(selectedDays: selectedDays.filter({ $0 != index + 2}))
                                                } else {
                                                    var selectedDays = daily.selectedDays
                                                    selectedDays.append(index + 2)
                                                    self.daily = .init(selectedDays: selectedDays)
                                                }
                                            }
                                    }
                                }
                                .padding(.top, 5)
                            case .weekly:
                                sectionTitle("\(weekly.frequency) Times in a week")
                                    .padding(.top, 20)
                                
                                HStack(spacing: 5) {
                                    ForEach(1..<7, id: \.self) { index in
                                        let selectedColor: Color = User.isTurnDarkMode ? .white : .black
                                        let unselectedColor: Color = User.isTurnDarkMode ? Color("Black") : Color("Gray01")
                                        
                                        let selectedTextColor: Color = User.isTurnDarkMode ? .black : .white
                                        let unselectedTextColor: Color = User.isTurnDarkMode ? .white : .black
                                        
                                        let isSelected = index == weekly.frequency
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(isSelected ? selectedColor : unselectedColor)
                                            .frame(height: 50)
                                            .overlay(
                                                Text("\(index)")
                                                    .fontBold(16)
                                                    .foregroundStyle(
                                                        isSelected ? selectedTextColor : unselectedTextColor
                                                    )
                                            )
                                            .onTapGesture {
                                                weekly = .init(frequency: index)
                                            }
                                    }
                                }
                                .padding(.top, 5)
                            case .monthly:
                                sectionTitle("Time on Month")
                                    .padding(.top, 20)
                                
                                HStack(spacing: 12) {
                                    ForEach(Frequency.Monthly.TimeOfMonth.allCases, id: \.self) { type in
                                        ZStack {
                                            let selectedColor: Color = User.isTurnDarkMode ? .white : .black
                                            let unselectedColor: Color = User.isTurnDarkMode ? Color("Black") : Color("Gray01")
                                            
                                            let selectedTextColor: Color = User.isTurnDarkMode ? .black : .white
                                            let unselectedTextColor: Color = User.isTurnDarkMode ? .white : .black
                                            
                                            type == self.monthly.type ? selectedColor : unselectedColor
                                            
                                            Text(type.rawValue.capitalized)
                                                .fontBold(18)
                                                .foregroundStyle(type == self.monthly.type ? selectedTextColor : unselectedTextColor)
                                        }
                                        .frame(height: 50)
                                        .cornerRadius(5)
                                        .onTapGesture {
                                            self.monthly.type = type
                                        }
                                    }
                                }
                                .padding(.top, 5)
                                
                                Text(monthly.type.description)
                                    .fontRegular(12)
                                    .foregroundStyle(Color("Gray"))
                                    .padding(.top, 5)
                            }
                            
                            reminderSection
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                }
                
                Text("Done")
                    .fontBold(20)
                    .frame(height: 28)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 15)
                    .background(Color.black)
                    .cornerRadius(5)
                    .foregroundColor(.white)
                    .onTapGesture {
                        withAnimation {
                            didAppear = false
                            doneAction(.init(type: type, daily: daily, weekly: weekly, monthly: monthly))
                        }
                    }
            }
        }
        .overlay(
            ZStack {
                if isShowingTimeDialog {
                    let currentTime = Date()
                    let time = editingTime ?? .init(hour: currentTime.hour, minutes: currentTime.minute)
                    TimeDialog(time: time) {
                        self.editingTime = nil
                        withAnimation {
                            self.isShowingTimeDialog = false
                        }
                    } doneAction: { time in
                        if let editingTime {
                            switch type {
                            case .daily:
                                if let index = daily.reminder.firstIndex(of: editingTime) {
                                    daily.reminder[index] = time
                                }
                            case .weekly:
                                break
                            case .monthly:
                                if let index = monthly.reminder.firstIndex(of: editingTime) {
                                    monthly.reminder[index] = time
                                }
                            }
                        } else {
                            switch type {
                            case .daily:
                                if !daily.reminder.contains(where: { $0 == time }) {
                                    daily.reminder.append(time)
                                }
                            case .weekly:
                                break
                            case .monthly:
                                if !monthly.reminder.contains(where: { $0 == time }) {
                                    monthly.reminder.append(time)
                                }
                            }
                        }
                        
                        self.editingTime = nil
                        
                        withAnimation {
                            self.isShowingTimeDialog = false
                        }
                    }
                }
            }
        )
        .offset(y: didAppear ? 0 : UIScreen.main.bounds.height)
        .onAppear {
            withAnimation {
                didAppear = true
            }
        }
    }
    
    // MARK: - Reminder
    @ViewBuilder
    var reminderSection: some View {
        sectionTitle("Reminder")
            .padding(.top, 20)
        
        switch type {
        case .daily:
            ForEach(daily.reminder.indices, id: \.self) { index in
                let time = daily.reminder[index]
                Color("Gray01")
                    .frame(height: 56)
                    .cornerRadius(12)
                    .overlay(
                        HStack {
                            Text(time.description)
                                .fontBold(18)
                                
                            Spacer()
                            
                            Image("ic_x")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 21, height: 21)
                                .foregroundColor(Color("Secondary"))
                                .onTapGesture {
                                    daily.reminder.removeAll(where: { $0 == time })
                                }
                        }.padding(.horizontal, 16)
                    )
                    .onTapGesture {
                        self.editingTime = time
                        withAnimation {
                            self.isShowingTimeDialog = true
                        }
                    }
            }
        case .weekly:
            reminderWeekly()
        case .monthly:
            ForEach(monthly.reminder.indices, id: \.self) { index in
                let time = monthly.reminder[index]
                Color("Gray01")
                    .frame(height: 56)
                    .cornerRadius(12)
                    .overlay(
                        HStack {
                            Text(time.description)
                                .fontBold(18)
                                
                            Spacer()
                            
                            Image("ic_x")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 21, height: 21)
                                .foregroundColor(Color("Secondary"))
                                .onTapGesture {
                                    monthly.reminder.removeAll(where: { $0 == time })
                                }
                        }.padding(.horizontal, 16)
                    )
                    .onTapGesture {
                        self.editingTime = time
                        withAnimation {
                            self.isShowingTimeDialog = true
                        }
                    }
            }
        }
        
        if type != .weekly {
            Color("Gray01")
                .frame(height: 56)
                .cornerRadius(12)
                .overlay(
                    HStack {
                        Text("Add")
                            .fontBold(18)
                            
                        Spacer()
                    }.padding(.horizontal, 16)
                )
                .onTapGesture {
                    withAnimation {
                        self.isShowingTimeDialog = true
                    }
                }
        }
    }
    
    @ViewBuilder
    func reminderWeekly() -> some View {
        Color("Gray01")
            .frame(height: 56)
            .cornerRadius(12)
            .overlay(
                HStack {
                    Text("None")
                        .fontBold(18)
                        
                    Spacer()
                    
                    if weekly.reminder.isEmpty {
                        Image(systemName: "checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 21, height: 21)
                            .foregroundColor(Color("Primary"))
                    }
                }.padding(.horizontal, 16)
            )
            .onTapGesture {
                weekly.reminder = []
            }
        
        Color("Gray01")
            .frame(height: 56)
            .cornerRadius(12)
            .overlay(
                HStack {
                    Text("Morning")
                        .fontBold(18)
                        
                    Spacer()
                    
                    if weekly.reminder.contains(where: { $0 == Time.morning()}) {
                        Image(systemName: "checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 21, height: 21)
                            .foregroundColor(Color("Primary"))
                    }
                }.padding(.horizontal, 16)
            )
            .onTapGesture {
                weekly.reminder = [Time.morning()]
            }
        
        Color("Gray01")
            .frame(height: 56)
            .cornerRadius(12)
            .overlay(
                HStack {
                    Text("Afternoon")
                        .fontBold(18)
                        
                    Spacer()
                    
                    if weekly.reminder.contains(where: { $0 == Time.afternoon()}) {
                        Image(systemName: "checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 21, height: 21)
                            .foregroundColor(Color("Primary"))
                    }
                }.padding(.horizontal, 16)
            )
            .onTapGesture {
                weekly.reminder = [Time.afternoon()]
            }
        
        Color("Gray01")
            .frame(height: 56)
            .cornerRadius(12)
            .overlay(
                HStack {
                    Text("Evening")
                        .fontBold(18)
                        
                    Spacer()
                    
                    if weekly.reminder.contains(where: { $0 == Time.evening()}) {
                        Image(systemName: "checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 21, height: 21)
                            .foregroundColor(Color("Primary"))
                    }
                }.padding(.horizontal, 16)
            )
            .onTapGesture {
                weekly.reminder = [Time.evening()]
            }
    }
    
    // MARK: - Repeat type
    @ViewBuilder
    var repeatSection: some View {
        sectionTitle("Repeat")
        
        HStack(spacing: 12) {
            ForEach(Frequency.RepeatType.allCases, id: \.self) { type in
                ZStack {
                    let selectedColor: Color = User.isTurnDarkMode ? .white : .black
                    let unselectedColor: Color = User.isTurnDarkMode ? Color("Black") : Color("Gray01")
                    
                    let selectedTextColor: Color = User.isTurnDarkMode ? .black : .white
                    let unselectedTextColor: Color = User.isTurnDarkMode ? .white : .black
                    
                    type == self.type ? selectedColor : unselectedColor
                    
                    Text(type.rawValue.capitalized)
                        .fontBold(18)
                        .foregroundStyle(type == self.type ? selectedTextColor : unselectedTextColor)
                }
                .frame(height: 50)
                .cornerRadius(5)
                .onTapGesture {
                    self.type = type
                }
            }
        }
    }
    
    func sectionTitle(_ text: String) -> some View {
        HStack {
            Text(text)
                .fontBold(23)
                .foreColor(mainColor)
            Spacer()
        }
    }
    
    func isSelectedDay(_ index: Int) -> Bool {
        return daily.selectedDays.contains(where: { $0 == index + 2})
    }
    
    // MARK: - Get
    var backgroundColor: Color {
        return User.isTurnDarkMode ? .black : .white
    }
    
    var mainColor: Color {
        return User.isTurnDarkMode ? .white : .black
    }
}

#Preview {
    CreateView(viewModel: .init(habit: nil))
}
