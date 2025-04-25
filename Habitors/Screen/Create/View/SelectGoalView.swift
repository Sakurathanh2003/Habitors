//
//  SelectGoalView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 5/4/25.
//

import SwiftUI
import SwiftUIIntrospect
import SakuraExtension

struct SelectGoalView: View {
    @ObservedObject var viewModel: CreateViewModel
    @State var currentUnit: GoalUnit = .count
    @State var isShowingSelectUnit: Bool = false
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            withAnimation {
                                viewModel.isShowingSelectGoalView = false
                            }
                        } label: {
                            Image("ic_x")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .foreColor(mainColor)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 46)
                    .overlay(
                        Text("Goal")
                            .fontBold(30)
                            .foreColor(mainColor)
                    )
                    
                    unitView
                        .padding(.horizontal, 17)
                        .padding(.top, 26)
                    
                    valueView
                        .padding(.horizontal, 17)
                        .padding(.top, 25)
                    
                    Spacer()
                }
            }
        }
        .overlay(
            ZStack {
                Color.black.opacity(0.5).ignoresSafeArea()
                    .opacity(isShowingSelectUnit ? 1 : 0)
                
                selectUnitDialog
                    .offset(y: isShowingSelectUnit ? 0 : UIScreen.main.bounds.height)
            }
        )
        .offset(y: viewModel.isShowingSelectGoalView ? 0 : UIScreen.main.bounds.height)
    }
    
    // MARK: - Select Unit Dialog
    var selectUnitDialog: some View {
        VStack {
            Spacer()
            
            VStack {
                HStack(spacing: 0) {
                    Text("Cancel")
                        .fontRegular(18)
                        .onTapGesture {
                            withAnimation {
                                isShowingSelectUnit = false
                            }
                        }
                    
                    Spacer()
                    Text("Done")
                        .fontSemiBold(18)
                        .foregroundStyle(Color("Error"))
                        .onTapGesture {
                            viewModel.goalUnit = currentUnit
                            withAnimation {
                                isShowingSelectUnit = false
                            }
                        }
                }
                .padding(.horizontal, 20)
                .frame(height: 56)
                .overlay(
                    Text("Select Unit")
                        .fontSemiBold(18)
                )
                
                Picker("", selection: $currentUnit) {
                    ForEach(GoalUnit.custom(), id: \.self) { unit in
                        Text(unit.rawValue.capitalized)
                            .fontSemiBold(18)
                            .frame(height: 40)
                            .tag(unit)
                    }
                }
                .pickerStyle(.wheel)
                .introspect(.picker(style: .wheel), on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) {
                    $0.subviews[1].backgroundColor = UIColor.red
                                       .withAlphaComponent(0)
                }
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 0) {
                        Spacer()
                        Color.gray.frame(height: 1)
                        Spacer().frame(height: 40)
                        Color.gray.frame(height: 1)

                        Spacer()
                    }
                )
            }
            .background(
                Color.white.ignoresSafeArea()
            )
        }
    }
    
    // MARK: - Unit Value
    var valueView: some View {
        VStack(spacing: 0) {
            sectionTitle("Enter value (\(viewModel.goalUnit.rawValue))")
            
            Color("Gray01")
                .frame(height: 56)
                .cornerRadius(12)
                .overlay(
                    HStack {
                        Text("\(viewModel.goalValue.text)")
                            .fontBold(18)
                        
                        + Text(" \(viewModel.goalUnit.rawValue)/day")
                            .fontSemiBold(18)
                            .foregroundColor(Color("Gray"))
                        
                        Spacer(minLength: 0)
                    }.padding(.horizontal, 16)
                )
                .onTapGesture {
                    withAnimation {
                        viewModel.isShowingChangeValueGoal = true
                    }
                }
                .padding(.top, 15)
        }
    }
    
    // MARK: - Unit View
    @ViewBuilder
    var unitView: some View {
        VStack(spacing: 0) {
            sectionTitle("Unit")
            
            Color("Gray01")
                .frame(height: 56)
                .cornerRadius(12)
                .overlay(
                    HStack {
                        Text(viewModel.goalUnit.rawValue.capitalized)
                            .fontBold(19)
                            .foregroundColor(Color("Black"))
                        
                        Spacer(minLength: 0)
                        Image("ic_arrow_right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 21, height: 21)
                    }.padding(.horizontal, 16)
                )
                .onTapGesture {
                    currentUnit = viewModel.goalUnit
                    withAnimation {
                        isShowingSelectUnit = true
                    }
                }
                .padding(.top, 15)
        }
    }
    
    func sectionTitle(_ text: String, toggle: Binding<Bool>? = nil) -> some View {
        HStack {
            Text(text)
                .fontBold(23)
                .foreColor(mainColor)
            
            Spacer()
            
            if let toggle {
                HabitToggle(isOn: toggle)
            }
        }
        .frame(height: 29)
    }
    
    // MARK: - Get
    var backgroundColor: Color {
        return viewModel.isTurnDarkMode ? .black : .white
    }
    
    var mainColor: Color {
        return viewModel.isTurnDarkMode ? .white : .black
    }
}

#Preview {
    SelectGoalView(viewModel: .init(habit: nil))
}
