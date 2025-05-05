//
//  ChooseTemplateHabitView.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import SwiftUI
import RxSwift
import SakuraExtension

struct ChooseTemplateHabitView: View {
    @ObservedObject var viewModel: ChooseTemplateHabitViewModel
    
    var body: some View {
        VStack {
            navigationBar
            ScrollView {
                VStack(spacing: 25)  {
                    Button(action: {
                        viewModel.input.selectCustom.onNext(())
                    }, label: {
                        HStack(spacing: 0) {
                            Image(systemName: "plus.circle.fill")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .padding(.trailing, 16)
                        
                            Text(viewModel.isVietnameseLanguage ? "Tự tạo thói quen" : "Custom Habit")
                                .fontBold(16)
                                .autoresize(1)
                            
                            Spacer(minLength: 0)
                        }
                        .padding(10)
                        .frame(height: 56)
                        .background(Color("Gray01"))
                        .cornerRadius(5)
                        .foregroundColor(.black)
                    })
                    
                    ForEach(viewModel.habitCategories, id: \.id) { category in
                        VStack(alignment: .leading) {
                            Text(category.name)
                                .fontBold(24)
                                .foreColor(mainColor)
                            
                            LazyVGrid(columns: [.init(spacing: 15), .init()], spacing: 15, content: {
                                
                                ForEach(category.items, id: \.name) { item in
                                    HStack(spacing: 0) {
                                        Text(item.icon)
                                            .fontBold(16)
                                            .padding(.trailing, 16)
                                        Text(item.name)
                                            .fontBold(16)
                                            .autoresize(1)
                                        
                                        Spacer(minLength: 0)
                                    }
                                    .padding(10)
                                    .frame(height: 56)
                                    .background(Color("Gray01"))
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        viewModel.input.selectTemplate.onNext(item)
                                    }
                                }
                            })
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
        .background(backgroundColor.ignoresSafeArea())
    }
    
    var navigationBar: some View {
        HStack {
            Text(viewModel.title)
                .fontBold(28)
                .foreColor(mainColor)
            
            Spacer()
            
            Button(action: {
                viewModel.routing.stop.onNext(())
            }, label: {
                Image("ic_x")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .foreColor(mainColor)
            })
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
    }
}

// MARK: - Get
extension ChooseTemplateHabitView {
    var backgroundColor: Color {
        return viewModel.isTurnDarkMode ? .black : .white
    }
    
    var mainColor: Color {
        return viewModel.isTurnDarkMode ? .white : .black
    }
}

#Preview {
    ChooseTemplateHabitView(viewModel: .init())
}
