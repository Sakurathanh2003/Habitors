//
//  HomeDiscoverView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 14/3/25.
//

import SakuraExtension
import SwiftUI

fileprivate struct Const {
    static let horizontalPadding: CGFloat = 24.0
    
    static let itemSpacing = 16.0
    static let itemWidth = (UIScreen.main.bounds.width - horizontalPadding * 2 - itemSpacing) / 2
    static let itemRatio: CGFloat = 156 / 170
    static let itemHeight = itemWidth / itemRatio
    static let itemCorner = itemWidth / 156 * 12

    static let imageWidth = itemWidth / 156 * 60
    static let textSize = itemWidth / 156 * 16
    static let elementSpacing = itemWidth / 156 * 20
}

struct HomeDiscoverView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var articles = [Article]()
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading) {
                        LazyVGrid(columns: [.init(spacing: Const.itemSpacing), .init()],alignment: .center, spacing: Const.itemSpacing, content: {
                            ForEach(articles, id: \.id) { item in
                                discoveryItemView(item)
                                    .onTapGesture {
                                        viewModel.input.selectArticle.onNext(item)
                                    }
                            }
                        })
                    }
                }
                .padding(Const.horizontalPadding)
                .padding(.bottom, UIScreen.main.bounds.height / 2)
            }
        }
        .onAppear {
            let itemFileName = viewModel.isVietnameseLanguage ? "ListArticle_VN" : "ListArticle"
            let itemURL = Bundle.main.url(forResource: itemFileName, withExtension: "json")!
            let decoder = JSONDecoder()
            
            do {
                let itemdata = try Data(contentsOf: itemURL)
                self.articles = try decoder.decode([Article].self, from: itemdata)
            } catch {
                print(error)
            }
        }
    }
    
    func discoveryItemView(_ item: Article) -> some View {
        VStack(alignment: .leading,spacing: 10) {
            Image(item.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Const.itemWidth, height: Const.itemHeight)
                .cornerRadius(Const.itemCorner)
            
            Text(item.title)
                .fontRegular(15)
                .lineLimit(2)
                .foreColor(viewModel.mainColor)
            
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    HomeView(viewModel: .init())
}
