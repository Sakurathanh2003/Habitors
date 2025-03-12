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
        Circle()
            .fill(
                LinearGradient(stops: [
                    .init(color: Color("B7A9FF"), location: -0.5),
                    .init(color: Color("7E65FF"), location: 0.25),
                    .init(color: Color("924FFF"), location: 0.5),
                    .init(color: Color("Secondary2"), location: 1)
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .frame(width: 200, height: 200)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .fill(.white)
                    .frame(width: 85, height: 85)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("924FFF"))
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

#Preview {
    SplashView()
}
