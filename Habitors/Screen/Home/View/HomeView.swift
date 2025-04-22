//
//  HomeView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import SwiftUI
import RxSwift
import SakuraExtension

enum HomeTab: String {
    case home
    case overall
    case tools
    case discover
}

fileprivate struct Const {
    static let horizontalPadding: CGFloat = 24.0
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Namespace var animation
    
    @ObservedObject var player: AudioPlayer = .shared
    @State var isAudioOpening: Bool = false
    
    @ViewBuilder
    var body: some View {
        if let tool = viewModel.currentTool {
            ToolItemView(animation: animation, tool: tool, isOpening: true) {
                viewModel.currentTool = nil
            }
        } else if let currentItem = player.getItem(), isAudioOpening {
            AudioView(player: player, item: currentItem, isOpen: $isAudioOpening)
                .matchedGeometryEffect(id: "audioplayer", in: animation)
        } else {
            ZStack {
                VStack(spacing: 0) {
                    navigationBar
                        .padding(.horizontal, Const.horizontalPadding)
                    
                    switch viewModel.currentTab {
                    case .home:
                        content()
                    case .overall:
                        HomeActivityView(viewModel: HomeActivityViewModel())
                    case .tools:
                        HomeToolView(viewModel: viewModel, namespace: animation)
                    case .discover:
                        HomeDiscoverView(viewModel: viewModel)
                    }
                    
                    if let currentItem = player.getItem(), !isAudioOpening {
                        Color.black.frame(height: 1)
                        AudioView(player: player, item: currentItem, isOpen: $isAudioOpening)
                            .matchedGeometryEffect(id: "audioplayer", in: animation)
                            .onTapGesture {
                                withAnimation {
                                    isAudioOpening = true
                                }
                            }
                        Color.black.frame(height: 1)
                    }
                    
                    HomeTabbarView(viewModel: viewModel)
                }
            }.background(backgroundColor.ignoresSafeArea())
        }
    }
    
    // MARK: - Home Content
    @State var mood = Mood.allCases.randomElement()
    @ViewBuilder
    func content() -> some View {
        VStack(spacing: 0) {
            if let mood {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("How do you feel?")
                            .gilroySemiBold(16)
                        
                        Text("Tap to record")
                            .gilroyRegular(12)
                            .foreColor(.black.opacity(0.8))
                    }
                    Spacer()
                    Image("icon_\(mood.rawValue)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                }
                .padding(10)
                .background(mood.color.opacity(0.6))
                .background(.white)
                .cornerRadius(5, corners: .allCorners)
                .onTapGesture {
                    viewModel.routing.routeToMoodie.onNext(())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            
            calendarView
            
            if viewModel.tasks.isEmpty {
                VStack(spacing: 16) {
                    Image("ic_empty_task")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                        .padding(.top, 20)
                        .foreColor(.gray)
                        
                    Text("You have no habits scheduled for this day. Keep up the good work and enjoy your break! 😊")
                        .gilroyRegular(16)
                        .lineSpacing(5)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("Gray"))
                    Spacer(minLength: 0)
                }
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 16) {
                        ForEach(viewModel.tasks, id: \.id) { habit in
                            SingleTaskView(date: viewModel.selectedDate, habit: habit)
                                .onTapGesture {
                                    print("did tap")
                                    viewModel.input.selectHabit.onNext(habit)
                                }
                        }
                    }
                    .padding(.horizontal, Const.horizontalPadding)
                    .padding(.vertical, 24)
                }
                .mask(
                    LinearGradient(stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.05)
                    ], startPoint: .top, endPoint: .bottom)
                )
            }
        }
    }
        
    // MARK: - Calendar
    var calendarView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.dateInMonth, id: \.timeIntervalSince1970) { date in
                        DateView(isDarkMode: $viewModel.isTurnDarkMode,
                                 date: date,
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
                withAnimation {
                    proxy.scrollTo(date.format("dd"),
                                   anchor: .center)
                }
            }
            .onAppear {
                proxy.scrollTo(viewModel.selectedDate.format("dd"),
                               anchor: .center)
            }
        }
    }
    
    // MARK: - NavigationBar
    var navigationBar: some View {
        HStack {
            Text(viewModel.currentTab.rawValue.capitalized)
                .gilroyBold(28)
                .foregroundStyle(textColor)
            
            Spacer()
                    
            Button {
                viewModel.routing.routeToSetting.onNext(())
            } label: {
                Image("ic_setting")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(textColor)
            }
        }
        .frame(height: 56)
    }
}

// MARK: - Tabbar
fileprivate struct HomeTabbarView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        HStack {
            Spacer(minLength: 0)
            tabItemView(.home)
            Spacer(minLength: 0)
            tabItemView(.overall)
            Spacer(minLength: 0)
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
            Spacer(minLength: 0)
            tabItemView(.discover)
            Spacer(minLength: 0)
            tabItemView(.tools)
            Spacer(minLength: 0)
        }
        .frame(height: 60)
        .padding(.top, 10)
    }
    
    @ViewBuilder
    func tabItemView(_ tab: HomeTab) -> some View {
        Button {
            viewModel.input.selectTab.onNext(tab)
        } label: {
            ZStack {
                Color.clear
                if viewModel.isSelected(tab) {
                    VStack(spacing: 4) {
                        Text(tab.rawValue.capitalized)
                            .gilroyBold(14)
                            .frame(height: 24)
                            .foregroundColor(textColor)
                        
                        Color("Primary")
                            .frame(width: 10, height: 3)
                            .cornerRadius(3)
                    }
                   
                } else {
                    Image("tab_\(tab.rawValue)")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foreColor(.gray)
                }
            }
            .frame(width: 60)
        }
    }
    
    var textColor: Color {
        return viewModel.isTurnDarkMode ? .white : .black
    }
}

// MARK: - Get
extension HomeView {
    var backgroundColor: Color {
        return viewModel.isTurnDarkMode ? .black : .white
    }
    
    var textColor: Color {
        return viewModel.isTurnDarkMode ? .white : .black
    }
}

#Preview {
    HomeView(viewModel: .init())
}
