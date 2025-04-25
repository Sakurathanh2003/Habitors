//
//  NavigationBarView.swift
//  Habitors
//
//  Created by Thanh Vu on 22/4/25.
//

import SwiftUI
import SakuraExtension

struct NavigationBarView: View {
    var title: String
    var secondItem: AnyView?
    var isDarkMode: Bool
   
    var backAction: (() -> Void)
    
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    backAction()
                }
            } label: {
                Image("ic_back")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foreColor(isDarkMode ? .white : .black)
            }
            
            Spacer()
            
            if let secondItem {
                secondItem
            }
        }
        .overlay(
            Text(title)
                .fontBold(18)
                .foreColor(isDarkMode ? .white : .black)
        )
        .frame(height: 56)
    }
}

#Preview {
    NavigationBarView(
        title: "Hello",
        secondItem: nil,
        isDarkMode: false,
        backAction: {
            print("Back tapped")
        }
    )
}
