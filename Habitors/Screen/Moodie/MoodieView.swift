//
//  MoodieView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 16/4/25.
//

import SwiftUI

struct MoodieView: View {
    @ObservedObject var viewModel: MoodieViewModel
    var body: some View {
        VStack {
            navigationBar
            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    var navigationBar: some View {
        HStack {
            Image("ic_back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .onTapGesture {
                  //  viewModel.routing.stop.onNext(())
                }
            
            Spacer()
        }
        .overlay(
            Text("Moodie")
                .gilroyBold(18)
        )
        .frame(height: 56)
    }
}

#Preview {
    MoodieView(viewModel: MoodieViewModel())
}
