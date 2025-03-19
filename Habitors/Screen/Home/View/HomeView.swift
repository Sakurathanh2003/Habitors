//
//  HomeView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import SwiftUI
import RxSwift

enum HomeTab: String {
    case home
    case activity
    case tools
    case discover
}

fileprivate struct Const {
    static let horizontalPadding: CGFloat = 24.0
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Namespace var animation
    
    var theme: AppTheme {
        return .theme1
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                navigationBar
                    .padding(.horizontal, Const.horizontalPadding)
                
                switch viewModel.currentTab {
                case .home:
                    content
                case .activity:
                    HomeActivityView(viewModel: viewModel)
                case .tools:
                    HomeToolView(viewModel: viewModel, namespace: animation)
                case .discover:
                    HomeDiscoverView(viewModel: viewModel)
                }
                
                HomeTabbarView(viewModel: viewModel)
            }
            .onAppear(perform: {
                viewModel.selectedDate = Date()
            })
            
            if let item = viewModel.showingToolItem {
                MusicToolDetailView(dismiss: {
                    self.viewModel.showingToolItem = nil
                }, item: item, namespace: animation)
            }
        }
        .background(theme.backgroundColor.ignoresSafeArea())
    }
    
    // MARK: - Home Content
    var content: some View {
        VStack(spacing: 0) {
            summaryView
                .padding(.horizontal, Const.horizontalPadding)
                .padding(.top, 22)
            calendarView
                .padding(.top, 24)
            
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    if viewModel.tasks.isEmpty {
                        Image("ic_empty_task")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                        
                        Text("You have no habits scheduled for this day. Keep up the good work and enjoy your break! 😊")
                            .gilroyRegular(16)
                            .lineSpacing(5)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color("Gray"))
                            
                    } else {
                        ForEach(0..<15) { index in
                            SingleTaskView(task: Task(name: "Task \(index + 1)", isCompleted: index % 2 == 0, date: Date()))
                        }
                    }
                }
                .padding(.horizontal, Const.horizontalPadding)
                .padding(.vertical, 24)
            }
            .mask(
                LinearGradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.1)
                ], startPoint: .top, endPoint: .bottom)
            )
        }
    }
        
    // MARK: - Calendar
    var calendarView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.dateInMonth, id: \.timeIntervalSince1970) { date in
                        DateView(date: date,
                                 isSelected: viewModel.isSelectedDate(date))
                        .id(date.format("dd"))
                        .onTapGesture {
                            viewModel.input.selectDate.onNext(date)
                        }
                    }
                }
                .padding(.horizontal, Const.horizontalPadding)
            }
            .onChange(of: viewModel.selectedDate) { date in
                if let date {
                    withAnimation {
                        proxy.scrollTo(date.format("dd"),
                                       anchor: .center)
                    }
                }
            }
        }
    }
    
    // MARK: - Summary View
    var summaryView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                let dateDescription = Date().format("EEEE\ndd MMMM, yyyy")
                Text(dateDescription)
                    .gilroyRegular(12)
                    .padding(.top, 16)
                
                if viewModel.todayTasks.isEmpty {
                    Text("Your tasks are\ncompleted")
                        .gilroyBold(28)
                        .autoresize(2)
                        .lineSpacing(5)
                        .padding(.bottom, 24)
                } else {
                    Text("You have\n4 tasks to do")
                        .gilroyBold(28)
                        .autoresize(2)
                        .lineSpacing(5)
                        .padding(.bottom, 24)
                }
                
            }
           
            Spacer(minLength: 0)
            
            Image("home_need_to_do")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 127)
        }
        .foregroundColor(.white)
        .padding(.leading, 20)
        .background(
            Color("Primary")
                .overlay(
                    Image("background_region")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(x: -UIScreen.main.bounds.width / 3)
                )
        )
        .cornerRadius(9)
    }
    
    
    // MARK: - NavigationBar
    var navigationBar: some View {
        HStack {
            VStack(alignment: .leading) {
                if viewModel.currentTab == .home {
                    Text("Good evening 🖐️")
                        .gilroyMedium(14)
                        .foregroundStyle(Color("Gray"))
                    
                    Text("SaberAli")
                        .gilroyBold(28)
                        .foregroundStyle(Color("Black"))
                } else {
                    Text(viewModel.currentTab.rawValue.capitalized)
                        .gilroyBold(28)
                        .foregroundStyle(Color("Black"))
                }
            }
            
            Spacer()
            
            Image("ic_setting")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        }
        .frame(height: 56)
    }
}

// MARK: - Tabbar
fileprivate struct HomeTabbarView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        HStack {
            tabItemView(.home)
            tabItemView(.activity)
            
            Circle()
                .fill(Color("Black"))
                .frame(width: 59, height: 59)
                .overlay(
                    Image("ic_plus")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                        
                )
                .onTapGesture {
                    viewModel.routing.routeToCreate.onNext(())
                }
            
            tabItemView(.discover)
            tabItemView(.tools)
        }
        .frame(height: 60)
        .padding(.top, 10)
        .background(
            VStack(spacing: 0) {
                Color("Secondary").frame(height: 1)
                Color.white.ignoresSafeArea()
            }
        )
    }
    
    @ViewBuilder
    func tabItemView(_ tab: HomeTab) -> some View {
        ZStack {
            Color.clear
            if viewModel.isSelected(tab) {
                VStack(spacing: 4) {
                    Text(tab.rawValue.capitalized)
                        .gilroyBold(14)
                        .frame(height: 24)
                        .foregroundColor(Color("Black"))
                    
                    Color("Primary")
                        .frame(width: 10, height: 3)
                        .cornerRadius(3)
                }
               
            } else {
                Image("tab_\(tab.rawValue)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
        }
        .onTapGesture {
            viewModel.input.selectTab.onNext(tab)
        }
    }
}

#Preview {
    HomeView(viewModel: .init())
}
