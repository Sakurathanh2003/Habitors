//
//  HomeView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import SwiftUI

enum HomeTab: String {
    case home
    case activity
    case profile
    case discover
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            navigationBar
            
            ScrollView {
                VStack {
                    summaryView
                    calendarView
                }
            }
            
            HomeTabbarView(viewModel: viewModel)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Calendar
    var calendarView: some View {
        ScrollView(.horizontal) {
            HStack {
                ZStack {
                    Color.red
                    
                    VStack(spacing: 12) {
                        Text("Fri")
                            .gilroyRegular(12)
                            .foregroundStyle(Color("Gray"))
                        
                        Text("13")
                            .gilroySemiBold(16)
                            .foregroundStyle(Color("Gray"))
                    }
                }
                .frame(width: 52,height: 88)
               
            }
        }
    }
    
    // MARK: - Summary View
    var summaryView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Friday\n21 January, 2022")
                    .gilroyRegular(12)
                    .padding(.top, 16)
                
                Text("You have\n4 tasks to do")
                    .gilroyBold(28)
                    .autoresize(2)
                    .lineSpacing(5)
                    .padding(.bottom, 24)
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
                Text("Good evening 🖐️")
                    .gilroyMedium(14)
                    .foregroundStyle(Color("Gray"))
                
                Text("SaberAli")
                    .gilroyBold(28)
                    .foregroundStyle(Color("Black"))
            }
            
            Spacer()
            
            Image("ic_setting")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        }
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
            
            tabItemView(.discover)
            tabItemView(.profile)
        }
        .frame(height: 60)
        .background(Color.white.ignoresSafeArea())
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
