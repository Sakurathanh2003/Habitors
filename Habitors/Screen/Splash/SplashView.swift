//
//  SplashView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import SwiftUI

struct SplashView: View {
    @State var didAppear: Bool = false
    var body: some View {
        ZStack {
            User.isTurnDarkMode ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea()
            
            Circle()
                .fill(
                    LinearGradient(colors: [
                        Color("Primary"), Color("Secondary")
                    ], startPoint: .leading, endPoint: .trailing)
                )
                .frame(width: 200, height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white)
                        .frame(width: 85, height: 85)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(colors: [
                                    Color("Primary"), Color("Secondary")
                                ], startPoint: .leading, endPoint: .trailing))
                                .frame(width: 25, height: 25)
                                .offset(x: didAppear ? 20 : -20,
                                        y: didAppear ? -20 : 20)
                        )
                        .rotationEffect(.degrees(didAppear ? -45 : 45))
                    
                        
                )
                .animation(.easeInOut(duration: 2), value: didAppear)
                .onAppear(perform: {
                    didAppear = true
                })
        }
    }
}

#Preview {
    SplashView()
}
