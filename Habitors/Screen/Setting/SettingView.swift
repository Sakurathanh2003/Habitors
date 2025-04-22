//
//  SettingView.swift
//  Habitors
//
//  Created by Thanh Vu on 22/4/25.
//

import SwiftUI
import RxSwift

struct SettingView: View {
    @ObservedObject var viewModel: SettingViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    viewModel.routing.stop.onNext(())
                } label: {
                    Image("ic_back")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(mainColor)
                }

                Spacer()
            }
            .overlay(
                Text(title)
                    .gilroyBold(20)
                    .foregroundStyle(mainColor)
            )
            .frame(height: 56)
            .padding(.horizontal, 20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    HStack {
                        Text(viewModel.isVietnameseLanguage ? "Ngôn ngữ" : "Language")
                            .gilroySemiBold(16)
                            .foregroundStyle(mainColor)
                        
                        Spacer()
                        
                        Text("VN")
                            .gilroyBold(16)
                            .foregroundStyle(viewModel.isVietnameseLanguage ? mainColor : .gray)
                        HStack {
                            if !viewModel.isVietnameseLanguage {
                                Spacer()
                            }
                            
                            Circle()
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(viewModel.isVietnameseLanguage ? "vietnam" : "us")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                )
                            
                            if viewModel.isVietnameseLanguage {
                                Spacer()
                            }
                        }
                        .frame(width: 48)
                        .padding(3)
                        .background(mainColor)
                        .cornerRadius(24)
                        .onTapGesture {
                            withAnimation {
                                viewModel.input.didTapLanguageToggle.onNext(())
                            }
                        }
                        
                        Text("US")
                            .gilroyBold(16)
                            .foregroundStyle(!viewModel.isVietnameseLanguage ? mainColor : .gray)
                    }.frame(height: 56)
                    
                    HStack {
                        Text(viewModel.isVietnameseLanguage ? "Chế độ tối" : "Dark Mode")
                            .gilroySemiBold(16)
                            .foregroundStyle(mainColor)
                        
                        Spacer()
                        
                        Text(viewModel.isVietnameseLanguage ? "Tắt" : "Off")
                            .gilroyBold(16)
                            .foregroundStyle(!viewModel.isTurnDarkMode ? mainColor : .gray)
                        HStack {
                            if viewModel.isTurnDarkMode {
                                Spacer()
                            }
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 24, height: 24)
                            
                            if !viewModel.isTurnDarkMode {
                                Spacer()
                            }
                        }
                        .frame(width: 48)
                        .padding(3)
                        .background(viewModel.isTurnDarkMode ? Color("Primary") : Color.gray)
                        .cornerRadius(24)
                        .onTapGesture {
                            withAnimation {
                                viewModel.input.didTapDarkModeToggle.onNext(())
                            }
                        }
                        
                        Text(viewModel.isVietnameseLanguage ? "Bật" : "On")
                            .gilroyBold(16)
                            .foregroundStyle(viewModel.isTurnDarkMode ? mainColor : .gray)
                    }.frame(height: 56)
                }.padding(.horizontal, 20)
            }
        }
        .background(backgroundColor.ignoresSafeArea())
    }
}

extension SettingView {
    var backgroundColor: Color {
        if viewModel.isTurnDarkMode {
            return .black
        }
        
        return .white
    }
    
    var mainColor: Color {
        if viewModel.isTurnDarkMode {
            return .white
        }
        
        return .black
    }
    
    var title: String {
        if viewModel.isVietnameseLanguage {
            return "Cài đặt"
        }
        
        return "Setting"
    }
}

#Preview {
    SettingView(viewModel: .init())
}
