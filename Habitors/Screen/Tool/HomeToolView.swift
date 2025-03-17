//
//  HomeProfileView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 14/3/25.
//

import SwiftUI

fileprivate struct Const {
    static let horizontalPadding: CGFloat = 24.0
}

struct HomeToolView: View {
    @ObservedObject var viewModel: HomeViewModel
    var namespace: Namespace.ID
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.tools, id: \.id) { tool in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(tool.name)
                                .gilroySemiBold(18)
                            Spacer()
                            
                            if tool.items.count > 3 {
                                Text("See all")
                                    .gilroySemiBold(16)
                                    .underline()
                            }
                        }
                        .padding(.bottom, 10)
                        
                        ForEach(tool.items.prefix(3), id: \.name) { item in
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("Gray01"))
                                    .matchedGeometryEffect(id: "background_\(item.id)", in: namespace)
                                
                                HStack(spacing: 0) {
                                    if item.id != viewModel.showingToolItem?.id {
                                        Circle()
                                            .matchedGeometryEffect(id: "thumbnail_\(item.id)", in: namespace)
                                            .foregroundStyle(Color.red)
                                            .frame(width: 60, height: 60)
                                            .zIndex(1)
                                    }
                                    
                                    
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .matchedGeometryEffect(id: "name_\(item.id)", in: namespace)
                                            .font(item.id != viewModel.showingToolItem?.id ? Font.golroyMedium(16) : Font.golroySemiBold(30))
                                        
                                        if let description = item.description {
                                            Text(description)
                                                .gilroyRegular(item.id != viewModel.showingToolItem?.id ? 12 : 16)
                                                .matchedGeometryEffect(id: "description_\(item.id)", in: namespace)
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    Spacer(minLength: 0)
                                }
                                .padding(16)
                            }
                            .frame(height: 92)
                            .onTapGesture {
                    
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    viewModel.showingToolItem = item
                                }
                            }
                        }
                    }
                }
                
                Color.clear
            }
            .padding(Const.horizontalPadding)
        }
    }
}

#Preview {
    HomeView(viewModel: .init())
}
