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
    @State var weekly: Frequency.Weekly = .init(selectedDays: [2, 3, 4, 5, 6, 7, 8])
    @State var monthly: Frequency.Monthly = .init(type: .beginning)
        
    @State var didAppear: Bool = false
    
    var cancelAction: (() -> Void)
    var doneAction: ((Frequency) -> Void)
    
    init(frequency: Frequency, cancelAction: @escaping () -> Void, doneAction: @escaping (Frequency) -> Void) {
        self.type = frequency.type
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
                        Text(Translator.translate(key: "Frequency", isVietnamese: User.isVietnamese))
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
                                Spacer(minLength: 0)
                            case .weekly:
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
                                                    let selectedDays = weekly.selectedDays
                                                    self.weekly = .init(selectedDays: selectedDays.filter({ $0 != index + 2}))
                                                } else {
                                                    var selectedDays = weekly.selectedDays
                                                    selectedDays.append(index + 2)
                                                    self.weekly = .init(selectedDays: selectedDays)
                                                }
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
                                            
                                            Text(Translator.translate(key: type.rawValue.capitalized, isVietnamese: User.isVietnamese))
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
                                
                                Text(Translator.translate(key: monthly.type.description, isVietnamese: User.isVietnamese))
                                    .fontRegular(12)
                                    .foregroundStyle(Color("Gray"))
                                    .padding(.top, 5)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                }
                
                Text(Translator.translate(key: "Done"))
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
                            doneAction(.init(type: type, weekly: weekly, monthly: monthly))
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
                    
                    Text(Translator.translate(key: type.rawValue.capitalized))
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
            Text(Translator.translate(key: text, isVietnamese: User.isVietnamese))
                .fontBold(23)
                .foreColor(mainColor)
            Spacer()
        }
    }
    
    func isSelectedDay(_ index: Int) -> Bool {
        return weekly.selectedDays.contains(where: { $0 == index + 2})
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
