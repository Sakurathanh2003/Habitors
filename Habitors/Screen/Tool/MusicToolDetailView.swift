//
//  MusicToolDetailView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import SwiftUI

fileprivate struct Const {
    static let horizontalPadding: CGFloat = 24.0
}

struct MusicToolDetailView: View {
    var dismiss: (() -> Void)
    var item: Tool.Item
    var namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("White"))
                .matchedGeometryEffect(id: "background_\(item.id)", in: namespace)
                .ignoresSafeArea()
               
            
            VStack(spacing: 0) {
                HStack {
                    Image("ic_back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .onTapGesture {
                            withAnimation(.spring) {
                                self.dismiss()
                            }
                        }
                    
                    Spacer()
                }
                .frame(height: 56)
                .padding(.horizontal, Const.horizontalPadding)
               
               
                Circle()
                    .matchedGeometryEffect(id: "thumbnail_\(item.id)", in: namespace)
                    .foregroundStyle(Color.blue)
                    .padding(.horizontal, 50)
                
                Text(item.name)
                    .matchedGeometryEffect(id: "name_\(item.id)", in: namespace)
                    .gilroySemiBold(30)
                    .padding(.top, 20)
                
                if let description = item.description {
                    Text(description)
                        .gilroyRegular(16)
                        .matchedGeometryEffect(id: "description_\(item.id)", in: namespace)
                        .padding(.top, 5)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    HomeView(viewModel: .init())
}
