//
//  CreateView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import SwiftUI
import RxSwift
import SakuraExtension

fileprivate struct Const {
    static let horizontalPadding: CGFloat = 24
    
    static let itemSpacing: CGFloat = 12
    static let itemWidth = (UIScreen.main.bounds.width - itemSpacing * 6 - horizontalPadding * 2) / 7
    static let itemCorner = itemWidth / 36 * 8
    static let itemTextSize = itemWidth / 36 * 14
}

// MARK: - Main View
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
                if viewModel.canDelete {
                    deleteButton()
                }
                
                if viewModel.isShowingCalendar {
                    CalendarDialog(isAllowSelectedMore: false,
                                   selectedDate: [viewModel.startedDate], cancelAction: {
                        viewModel.input.selectStartedDate.onNext(nil)
                    }, doneAction: { dates in
                        viewModel.input.selectStartedDate.onNext(dates.first)
                    })
                }
                
                SelectGoalView(viewModel: viewModel)
                if viewModel.isShowingChangeValueGoal {
                    InputView(value: viewModel.goalValue, titleString: viewModel.isVietnameseLanguage ? "Nhập giá trị" : "Enter value", isShowing: $viewModel.isShowingChangeValueGoal, saveAction: {
                        if let value = Double($0) {
                            viewModel.goalValue = value
                        }
                    })
                }
                
                if viewModel.isShowingFrequency {
                    SelectFrequencyView(frequency: viewModel.frequency, cancelAction: {
                        viewModel.input.selectFrequency.onNext(nil)
                    }, doneAction: { frequency in
                        viewModel.input.selectFrequency.onNext(frequency)
                    })
                }
                
                if viewModel.isShowingIcon {
                    ChooseIconView(cancelAction: {
                        viewModel.input.selectIcon.onNext(nil)
                    }, doneAction: { iconName in
                        viewModel.input.selectIcon.onNext(iconName)
                    })
                }
                
                if viewModel.isShowingTimeDialog {
                    let currentTime = Date()
                    let time = viewModel.editingTime ?? .init(hour: currentTime.hour, minutes: currentTime.minute)
                    TimeDialog(time: time) {
                        viewModel.editingTime = nil
                        withAnimation {
                            viewModel.isShowingTimeDialog = false
                        }
                    } doneAction: { time in
                        
                        if let editingTime = viewModel.editingTime {
                            if let index = viewModel.reminder.firstIndex(where: { $0.hour == editingTime.hour && $0.minutes == editingTime.minutes}) {
                                viewModel.reminder[index] = time
                            }
                        } else {
                            if !viewModel.reminder.contains(where: { $0.hour == time.hour && $0.minutes == time.minutes }) {
                                viewModel.reminder.append(time)
                            }
                        }
                        
                        viewModel.editingTime = nil
                        
                        withAnimation {
                            viewModel.isShowingTimeDialog = false
                        }
                    }
                }
            }
        )
        .background(backgroundColor.ignoresSafeArea())
    }
    
    // MARK: - Delete
    private func deleteButton() -> some View {
        VStack {
            Spacer(minLength: 0)
            Button(action: {
                viewModel.input.wantToDelete.onNext(())
            }, label: {
                HStack {
                    Spacer()
                    Image("Recycle Bin")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                    
                    Text(viewModel.isVietnameseLanguage ? "Xoá thói quen này" : "Delete this habit")
                        .fontBold(18)
                    
                    Spacer()
                }
                .foregroundStyle(.white)
                .frame(height: 56)
                .cornerRadius(12)
                .background(
                    Color("Error").ignoresSafeArea()
                )
            })
        }
    }
    
    // MARK: - Frequency
    @ViewBuilder
    var repeatView: some View {
        VStack(alignment: .leading) {
            sectionTitle(Translator.translate(key: "Frequency"))
            
            Color("Gray01")
                .frame(height: 56)
                .cornerRadius(12)
                .overlay(
                    HStack {
                        Text(viewModel.frequency.description)
                            .fontBold(18)
                        
                        Spacer(minLength: 0)
                        
                        Image("ic_arrow_right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                    }.padding(.horizontal, 16)
                )
                .onTapGesture {
                    viewModel.isShowingFrequency = true
                }
        }
    }
    
    // MARK: - Reminder
    @ViewBuilder
    var reminderView: some View {
        VStack(alignment: .leading) {
            sectionTitle(viewModel.isVietnameseLanguage ? "Nhắc nhở" : "Reminder")
            
            VStack(spacing: 10) {
                ForEach(viewModel.reminder.indices, id: \.self) { index in
                    let time = viewModel.reminder[index]
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
                                        viewModel.reminder.removeAll(where: { $0 == time })
                                    }
                            }.padding(.horizontal, 16)
                        )
                        .onTapGesture {
                            viewModel.editingTime = time
                            withAnimation {
                                viewModel.isShowingTimeDialog = true
                            }
                        }
                }
                
                Color("Gray01")
                    .frame(height: 56)
                    .cornerRadius(12)
                    .overlay(
                        HStack {
                            Text(viewModel.isVietnameseLanguage ? "Thêm" : "Add")
                                .fontBold(18)
                            
                            Spacer()
                        }.padding(.horizontal, 16)
                    )
                    .onTapGesture {
                        withAnimation {
                            viewModel.isShowingTimeDialog = true
                        }
                    }
            }
        }
    }
    
    // MARK: - Habit date
    @ViewBuilder
    var dateAndPeriodView: some View {
        VStack(alignment: .leading, spacing: 5) {
            sectionTitle(viewModel.isVietnameseLanguage ? "Ngày bắt đầu thói quen" : "Habit start date")
            
            Color("Gray01")
                .frame(height: 56)
                .cornerRadius(12)
                .overlay(
                    HStack {
                        Text(viewModel.habitStartDateString)
                            .fontBold(18)
                        
                        Spacer(minLength: 0)
                        
                        Image("ic_arrow_right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
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
        if viewModel.canChangeName {
            VStack(alignment: .leading) {
                sectionTitle(viewModel.isVietnameseLanguage ? "Tên thói quen" : "Name")
                
                TextField(text: $viewModel.name) {
                    Text(viewModel.isVietnameseLanguage ? "Nhập tên thói quen" : "Enter your habit name")
                }
                .fontBold(18)
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
                        Text("\(viewModel.goalValue.text)")
                            .fontBold(18)
                        
                        + Text(" \(viewModel.goalUnit.description) / " + (viewModel.isVietnameseLanguage ? "ngày" : "day"))
                            .fontSemiBold(18)
                            .foregroundColor(Color("Gray"))
                        
                        Spacer(minLength: 0)
                        
                        Image("ic_arrow_right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                    }.padding(.horizontal, 16)
                )
                .onTapGesture {
                    viewModel.input.didSelectGoalView.onNext(())
                }
        }
    }
    
    // MARK: - Thumbnail
    var thumbnailView: some View {
        ZStack {
            HStack(spacing: 30) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("Secondary"))
                    .frame(width: 96, height: 96)
                    .overlay(
                        ZStack {
                            if let icon = viewModel.icon {
                                if icon.count == 1 {
                                    Text(icon)
                                        .font(.system(size: 50))
                                } else {
                                    Image(icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding()
                                }
                            }
                        }
                    )
                    .padding(2)
                    .blur(radius: 2)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("Primary"))
                    .frame(width: 96, height: 96)
                    .overlay(
                        ZStack {
                            if let icon = viewModel.icon {
                                if icon.count == 1 {
                                    Text(icon)
                                        .font(.system(size: 50))
                                } else {
                                    Image(icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding()
                                }
                            }
                        }
                    )
                    .padding(2)
                    .blur(radius: 2)
            }
            
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .frame(width: 112, height: 112)
                .shadow(radius: 5)
                .overlay(
                    ZStack {
                        if let icon = viewModel.icon {
                            if icon.count == 1 {
                                Text(icon)
                                    .font(.system(size: 50))
                            } else {
                                Image(icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding()
                            }
                        } else {
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .padding()
                        }
                    }
                )
                .onTapGesture {
                    withAnimation {
                        viewModel.isShowingIcon = true
                    }
                }
                .padding()
        }
    }
    
    var navigationBar: some View {
        HStack {
            Button(action: {
                viewModel.routing.stop.onNext(())
            }, label: {
                Image("ic_back")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .frame(width: 30, height: 30)
                    .foreColor(mainColor)
            })
        
            Spacer(minLength: 0)
            
            Button {
                viewModel.input.save.onNext(())
            } label: {
                Text(viewModel.isVietnameseLanguage ? "Lưu" : "Save")
                    .fontBold(18)
                    .foregroundStyle(Color("Primary"))
            }
        }
        .frame(height: 56)
        .overlay(
            Text(viewModel.title)
                .fontBold(20)
                .foreColor(mainColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 40)
        )
    }
}

// MARK: - Extension
extension CreateView {
    func sectionTitle(_ text: String, toggle: Binding<Bool>? = nil) -> some View {
        HStack {
            Text(text)
                .fontBold(18)
                .foreColor(mainColor)
            
            Spacer()
            
            if let toggle {
                HabitToggle(isOn: toggle)
            }
        }
        .frame(height: 29)
    }
    
    var backgroundColor: Color {
        return viewModel.isTurnDarkMode ? .black : .white
    }
    
    var mainColor: Color {
        return viewModel.isTurnDarkMode ? .white : .black
    }
}

#Preview {
    CreateView(viewModel: .init(habit: nil))
}
