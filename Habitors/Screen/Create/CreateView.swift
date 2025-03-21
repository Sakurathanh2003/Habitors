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

struct InputView: View {
    @Binding var isShowing: Bool
    @State var text: String = ""
    @State var title: String
    @State var didAppear: Bool = false
    var saveAction: ((String) -> Void)
    @FocusState private var keyboardFocused: Bool
    
    init(value: Int, titleString: String, isShowing: Binding<Bool>, saveAction: @escaping (String) -> Void) {
        self.text = "\(value)"
        self.title = titleString
        self.saveAction = saveAction
        self._isShowing = isShowing
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(didAppear ? 0.5 : 0).ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 0) {
                Spacer()
                VStack {
                    HStack {
                        Text(title)
                            .gilroyBold(20)
                        
                        Spacer()
                        
                        Image("ic_x")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .onTapGesture {
                                dismiss()
                            }
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 46)
                    
                    HStack {
                        TextField(text: $text) {
                            Text("Enter Value")
                                .gilroyBold(18)
                        }
                        .keyboardType(.numberPad)
                        .focused($keyboardFocused)
                        .gilroyBold(18)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .frame(height: 56)
                        .background(Color("Gray01"))
                        .cornerRadius(10)
                        
                        Text("Save")
                            .gilroyBold(16)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(Color("Error"))
                            .cornerRadius(5)
                            .foregroundColor(.white)
                            .onTapGesture {
                                saveAction(text)
                                dismiss()
                            }
                    }
                    .padding(.bottom, 5)
                    .padding(.horizontal, 20)
                }
                .background(Color.white.ignoresSafeArea())
            }
            .offset(y: didAppear ? 0 : UIScreen.main.bounds.height / 3)
        }
        .onAppear(perform: {
            withAnimation {
                didAppear = true
                keyboardFocused = true
            }
        })
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.5)) {
            keyboardFocused = false
            didAppear = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.isShowing = false
        }
    }
}

struct FrequencyView: View {
    @State var type: Frequency.RepeatType = .daily
    @State var daily: Frequency.Daily = .init(selectedDays: [2, 3, 4, 5, 6, 7, 8])
    @State var weekly: Frequency.Weekly = .init(frequency: 1)
    @State var monthly: Frequency.TimeOfMonth = .beginning
    
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
    
    @State var didAppear: Bool = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        Image("ic_x")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .onTapGesture {
                                withAnimation {
                                    didAppear = false
                                    cancelAction()
                                }
                            }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 46)
                    .overlay(
                        Text("Frequency")
                            .gilroyBold(30)
                    )
                    
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
                                        Circle()
                                            .fill(isSelected ? Color("Black") : Color("Gray02"))
                                            .overlay(
                                                Text(dates[index])
                                                    .gilroyBold(16)
                                                    .foregroundStyle(
                                                        isSelected ? Color.white : Color("Black")
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
                                        let isSelected = index == weekly.frequency
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(isSelected ? Color("Black") : Color("Gray02"))
                                            .frame(height: 50)
                                            .overlay(
                                                Text("\(index)")
                                                    .gilroyBold(16)
                                                    .foregroundStyle(
                                                        isSelected ? Color.white : Color("Black")
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
                                    ForEach(Frequency.TimeOfMonth.allCases, id: \.self) { type in
                                        ZStack {
                                            type == self.monthly ? Color("Black") : Color("Gray01")
                                            
                                            Text(type.rawValue.capitalized)
                                                .gilroyBold(18)
                                                .foregroundStyle(type == self.monthly ? Color.white : Color("Black"))
                                        }
                                        .frame(height: 50)
                                        .cornerRadius(5)
                                        .onTapGesture {
                                            self.monthly = type
                                        }
                                    }
                                }
                                .padding(.top, 5)
                                
                                Text(monthly.description)
                                    .gilroyRegular(12)
                                    .foregroundStyle(Color("Gray"))
                                    .padding(.top, 5)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                }
                
                Text("Done")
                    .gilroyBold(20)
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
        .offset(y: didAppear ? 0 : UIScreen.main.bounds.height)
        .onAppear {
            withAnimation {
                didAppear = true
            }
        }
    }
    
    @ViewBuilder
    var repeatSection: some View {
        sectionTitle("Repeat")
        
        HStack(spacing: 12) {
            ForEach(Frequency.RepeatType.allCases, id: \.self) { type in
                ZStack {
                    type == self.type ? Color("Black") : Color("Gray01")
                    
                    Text(type.rawValue.capitalized)
                        .gilroyBold(18)
                        .foregroundStyle(type == self.type ? Color.white : Color("Black"))
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
            Text(text).gilroyBold(23)
            Spacer()
        }
    }
    
    func isSelectedDay(_ index: Int) -> Bool {
        return daily.selectedDays.contains(where: { $0 == index + 2})
    }
}

struct CreateView: View {
    @ObservedObject var viewModel: CreateViewModel
    
    var body: some View {
        VStack {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    thumbnailView
                    
                    VStack(spacing: 24) {
                        nameField
                        goalView
                        
                        dateAndPeriodView
                        repeatView
                        reminderView
                    }
                    .padding(.top, 30)
                }
                .padding(.bottom, 100)
            }
        }
        .padding(.horizontal, Const.horizontalPadding)
        .overlay(
            ZStack {
                if viewModel.isShowingCalendar {
                    CalendarDialog(isAllowSelectedMore: false,
                                   selectedDate: [viewModel.startedDate], cancelAction: {
                        viewModel.input.selectStartedDate.onNext(nil)
                    }, doneAction: { dates in
                        viewModel.input.selectStartedDate.onNext(dates.first)
                    })
                }
                
                if viewModel.isShowingChangeValueGoal {
                    InputView(value: viewModel.goalValue, titleString: "Enter value (count)", isShowing: $viewModel.isShowingChangeValueGoal, saveAction: {
                        if let value = Int($0) {
                            viewModel.goalValue = value
                        }
                    })
                }
                
                if viewModel.isShowingTimeDialog {
                    let index = viewModel.editTimeIndex
                    let time = index != nil ? viewModel.times[index!] : Time(hour: 1, minutes: 1)
                    TimeDialog(time: time) {
                        viewModel.input.saveReminder.onNext(nil)
                    } doneAction: { time in
                        viewModel.input.saveReminder.onNext(time)
                    }
                }
                
                if viewModel.isShowingFrequency {
                    FrequencyView(frequency: viewModel.frequency, cancelAction: {
                        viewModel.input.selectFrequency.onNext(nil)
                    }, doneAction: { frequency in
                        viewModel.input.selectFrequency.onNext(frequency)
                    })
                }
            }
        )
        .background(Color.white.ignoresSafeArea())
    }
    
    // MARK: - Reminder
    @ViewBuilder
    var reminderView: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Reminder", toggle: $viewModel.isTurnOnReminder)
            
            if viewModel.isTurnOnReminder {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.times.indices, id: \.self) { index in
                            let time = viewModel.times[index]
                            Text(time.description)
                                .gilroySemiBold(14)
                                .foregroundStyle(Color("Gray"))
                                .padding(.horizontal, 15)
                                .frame(height: 30)
                                .background(Color.black)
                                .cornerRadius(5)
                                .onTapGesture {
                                    viewModel.input.selectEditReminder.onNext(time)
                                }
                        }
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
                        .onTapGesture {
                            viewModel.input.selectAddReminder.onNext(())
                        }
                }
            }
        }
    }
    
    // MARK: - Frequency
    @ViewBuilder
    var repeatView: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Frequency")
            
            Color("Gray01")
                .frame(height: 56)
                .cornerRadius(12)
                .overlay(
                    HStack {
                        Text(viewModel.frequency.description)
                            .gilroyBold(18)
                        
                        Spacer(minLength: 0)
                    }.padding(.horizontal, 16)
                )
                .onTapGesture {
                    viewModel.isShowingFrequency = true
                }
        }
    }
    
    // MARK: - Habit date
    @ViewBuilder
    var dateAndPeriodView: some View {
        VStack(alignment: .leading, spacing: 5) {
            sectionTitle("Habit start date")
            
            Color("Gray01")
                .frame(height: 56)
                .cornerRadius(12)
                .overlay(
                    HStack {
                        Text(viewModel.habitStartDateString)
                            .gilroyBold(18)
                        
                        Spacer(minLength: 0)
                    }.padding(.horizontal, 16)
                )
                .onTapGesture {
                    withAnimation {
                        viewModel.isShowingCalendar = true
                    }
                }
        }
    }
    
    // MARK: - Name
    @ViewBuilder
    var nameField: some View {
        if viewModel.habit == nil {
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
    }
    
    // MARK: - Goal
    @ViewBuilder
    var goalView: some View {
        VStack(alignment: .leading) {
            sectionTitle(viewModel.goalSectionTitle)
            
            Color("Gray01")
                .frame(height: 56)
                .cornerRadius(12)
                .overlay(
                    HStack {
                        Text("\(viewModel.goalValue)")
                            .gilroyBold(18)
                        
                        + Text(" \(viewModel.goalUnit.rawValue)/day")
                            .gilroySemiBold(18)
                            .foregroundColor(Color("Gray"))
                        
                        Spacer(minLength: 0)
                    }.padding(.horizontal, 16)
                )
                .onTapGesture {
                    withAnimation {
                        viewModel.isShowingChangeValueGoal = true
                    }
                }
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
            Button(action: {
                viewModel.routing.stop.onNext(())
            }, label: {
                Image("ic_back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .frame(width: 30, height: 30)
            })
        
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
            Text(viewModel.title)
                .gilroyBold(20)
                .foregroundStyle(Color("Black"))
        )
    }
    
   
}

// MARK: - Extension
extension CreateView {
    func sectionTitle(_ text: String, toggle: Binding<Bool>? = nil) -> some View {
        HStack {
            Text(text)
                .gilroyBold(18)
                .foregroundStyle(Color("Black"))
            
            Spacer()
            
            if let toggle {
                HabitToggle(isOn: toggle)
            }
        }
        .frame(height: 29)
    }
}

#Preview {
    CreateView(viewModel: .init(habit: .init(id: "", name: "Walk", icon: "🚶🏻‍♀️‍➡️", goalUnit: .steps, goalValue: 10000, isTemplate: true, frequency: .init())))
}
