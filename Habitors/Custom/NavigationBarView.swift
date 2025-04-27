//
//  NavigationBarView.swift
//  Habitors
//
//  Created by Thanh Vu on 22/4/25.
//

import SwiftUI
import SakuraExtension

enum SecondItemType {
    case more
}

struct NavigationBarView: View {
    var title: String
    var secondItem: SecondItemType?
    var isDarkMode: Bool
   
    var backAction: (() -> Void)
    var secondAction: (() -> Void)?
    
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
            
            Spacer(minLength: 10)
            
            Text(title)
                .fontBold(18)
                .autoresize(1)
                .foreColor(isDarkMode ? .white : .black)
            
            Spacer(minLength: 10)
            
            if let secondItem {
                switch secondItem {
                case .more:
                    Button(action: {
                        secondAction?()
                    }, label: {
                        Image(systemName: "ellipsis")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .frame(width: 30, height: 30)
                            .foreColor(isDarkMode ? .white : .black)
                    })
                }
            } else {
                Spacer(minLength: 34)
            }
        }
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
