//
//  HomeDiscoverView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 14/3/25.
//

import SwiftUI

fileprivate struct Const {
    static let horizontalPadding: CGFloat = 24.0
    
    static let itemSpacing = 16.0
    static let itemWidth = (UIScreen.main.bounds.width - horizontalPadding * 2 - itemSpacing) / 2
    static let itemRatio: CGFloat = 156 / 149
    static let itemHeight = itemWidth / itemRatio
    static let itemCorner = itemWidth / 156 * 12

    static let imageWidth = itemWidth / 156 * 60
    static let textSize = itemWidth / 156 * 16
    static let elementSpacing = itemWidth / 156 * 20
}

struct HomeDiscoverView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(alignment: .leading) {
                        Text("Most popular Habits")
                            .gilroySemiBold(18)
                        
                        LazyVGrid(columns: [.init(spacing: Const.itemSpacing), .init()],spacing: Const.itemSpacing, content: {
                            habit()
                            habit()
                            habit()
                            habit()
                        })
                        .padding(.top, 16)
                    }
                }
                
                Color.clear
            }
            .padding(Const.horizontalPadding)
        }
    }
    
    func habit() -> some View {
        VStack(spacing: Const.elementSpacing) {
            RoundedRectangle(cornerRadius: 4)
                .frame(width: Const.imageWidth, height: Const.imageWidth)
            
            Text("Meditate")
                .gilroySemiBold(Const.textSize)
        }
        .frame(width: Const.itemWidth, height: Const.itemHeight)
        .background(Color("Gray01"))
        .cornerRadius(Const.itemCorner)
    }
}

#Preview {
    HomeView(viewModel: .init())
}
