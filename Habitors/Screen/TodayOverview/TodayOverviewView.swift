//
//  TodayOverviewView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 5/4/25.
//

import SwiftUI
import RxSwift

enum OverviewTab: String {
    case inProgress = "In progress"
    case completed = "Completed"
}

struct TodayOverviewView: View {
    @State var currentTab: OverviewTab = .inProgress
    @ObservedObject var viewModel: TodayOverviewViewModel
    
    var body: some View {
        VStack {
            navigationBar
            tabbarView
            habitView
        }
        .padding(.horizontal, 20)
        .background(Color.white.ignoresSafeArea())
    }
    
    // MARK: - Habit view
    @ViewBuilder
    var habitView: some View {
        let habits = currentTab == .inProgress ? viewModel.inProgressHabit : viewModel.completedHabit
        
        if habits.isEmpty {
            emptyView(currentTab)
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(habits, id: \.id) { habit in
                        SingleTaskView(date: Date(), habit: habit)
                            .onTapGesture {
                                print("did tap")
                                viewModel.input.selectHabit.onNext(habit)
                            }
                    }
                }
                .padding(.vertical, 24)
            }
        }
    }
    
    // MARK: - Tabbar view
    var tabbarView: some View {
        HStack {
            tabItemView(tab: .inProgress)
                .onTapGesture {
                    withAnimation {
                        currentTab = .inProgress
                    }
                }
            
            tabItemView(tab: .completed)
                .onTapGesture {
                    withAnimation {
                        currentTab = .completed
                    }
                }
        }
        .frame(height: 40)
        .background(
            HStack(spacing: 0) {
                if currentTab == .completed {
                    Color.clear
                }
                
                Color.black.cornerRadius(8)
                
                if currentTab == .inProgress {
                    Color.clear
                }
            }
        )
        .padding(4)
        .background(
            Color("Gray02")
        )
        .cornerRadius(12)
    }
    
    func emptyView(_ tab: OverviewTab) -> some View {
        VStack(spacing: 16) {
            Image("ic_empty_task")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .padding(.top, 20)
            Text("You have no habits \(tab.rawValue.lowercased()) tab")
                .gilroyRegular(16)
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("Gray"))
            Spacer(minLength: 0)
        }
    }
    
    // MARK: - Navigation Bar
    var navigationBar: some View {
        HStack {
            Image("ic_back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .onTapGesture {
                    viewModel.input.selectBack.onNext(())
                }
            
            Spacer()
        }
        .overlay(
            Text("Overview")
                .gilroyBold(20)
        )
        .frame(height: 56)
    }
    
    // MARK: - Tab
    func tabItemView(tab: OverviewTab) -> some View {
        Color.clear
            .overlay(
                Text(tab.rawValue)
                    .gilroyRegular(14)
                    .foregroundStyle(tab == currentTab ? .white : Color("Gray"))
            )
    }
}

#Preview {
    TodayOverviewView(viewModel: .init())
}
