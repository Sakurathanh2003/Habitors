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
                    InputView(value: viewModel.goalValue, titleString: "Enter value (\(viewModel.goalUnit.rawValue)", isShowing: $viewModel.isShowingChangeValueGoal, saveAction: {
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
                
               
                
                if viewModel.isShowingDeleteDialog {
                    deleteDialog()
                }
            }
        )
        .background(Color.white.ignoresSafeArea())
    }
    
    // MARK: - Delete
    private func deleteDialog() -> some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 56, height: 56)
                    .padding(.top, 20)
                
                Text("Would you like to delete this habit?")
                    .gilroyBold(16)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                Text("You cannot undo this action")
                    .gilroyRegular(12)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
                
                HStack {
                    Button {
                        viewModel.input.delete.onNext(())
                    } label: {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.black, lineWidth: 1)
                            .overlay(
                                Text("Delete")
                                    .gilroyBold(16)
                                    .foregroundStyle(Color("Error"))
                            )
                    }

                    Button {
                        withAnimation {
                            viewModel.isShowingDeleteDialog = false
                        }
                    } label: {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.black, lineWidth: 1)
                            .overlay(
                                Text("Cancel")
                                    .gilroyBold(16)
                                    .foregroundStyle(.black)
                            )
                    }
                }
                .frame(height: 40)
                .padding(.top, 20)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(5)
            .padding(.horizontal, 56)
        }
    }
    
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
                    
                    Text("Delete this habit")
                        .gilroyBold(18)
                    
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
        if viewModel.canChangeName {
            VStack(alignment: .leading) {
                sectionTitle("Name")
                
                TextField(text: $viewModel.name) {
                    Text("Enter your habit name")
                }
                .gilroyBold(18)
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
                            .gilroyBold(18)
                        
                        + Text(" \(viewModel.goalUnit.description)/day")
                            .gilroySemiBold(18)
                            .foregroundColor(Color("Gray"))
                        
                        Spacer(minLength: 0)
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
                            } else {
                                Image(systemName: "plus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .padding()
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
                            } else {
                                Image(systemName: "plus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .padding()
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
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .frame(width: 30, height: 30)
            })
        
            Spacer(minLength: 0)
            
            Button {
                viewModel.input.save.onNext(())
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
    CreateView(viewModel: .init(habit: nil))
}
