//
//  HomeView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import SwiftUI



struct HomeView: View {
    var body: some View {
        VStack {
            navigationBar
            
            Spacer()
            tabbar
        }
        .padding(.horizontal, 24)
    }
    
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
    
    var tabbar: some View {
        HStack {
            
        }
    }
}

#Preview {
    HomeView()
}
