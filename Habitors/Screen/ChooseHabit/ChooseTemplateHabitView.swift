//
//  ChooseTemplateHabitView.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import SwiftUI
import RxSwift

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
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .padding(.trailing, 16)
                                
                            Text("Create Custom Habit")
                                .gilroyBold(16)
                                .autoresize(1)
                            
                            Spacer(minLength: 0)
                        }
                        .padding(10)
                        .frame(height: 56)
                        .background(Color("Gray01"))
                        .cornerRadius(5)
                        .foregroundColor(.black)
                    })
                    
                    ForEach(AppConst.habitCategories, id: \.id) { category in
                        VStack(alignment: .leading) {
                            Text(category.name)
                                .gilroyBold(24)
                            
                            LazyVGrid(columns: [.init(spacing: 15), .init()], spacing: 15, content: {
                                
                                ForEach(category.items, id: \.name) { item in
                                    HStack(spacing: 0) {
                                        Text(item.icon)
                                            .gilroyBold(16)
                                            .padding(.trailing, 16)
                                        Text(item.name)
                                            .gilroyBold(16)
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
        .background(Color.white.ignoresSafeArea())
    }
    
    var navigationBar: some View {
        HStack {
            Text("Choose Habit")
                .gilroyBold(30)
            
            Spacer()
            
            Button(action: {
                viewModel.routing.stop.onNext(())
            }, label: {
                Image("ic_x")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
            })
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
    }
}

#Preview {
    ChooseTemplateHabitView(viewModel: .init())
}
