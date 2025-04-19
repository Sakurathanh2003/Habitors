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
    @State var categories = [ArticleCategory]()
    @State var articles = [Article]()
    @State var currentCategoryIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { proxy in
                    HStack {
                        ForEach(0..<categories.count, id: \.self) { index in
                            let isSelected = currentCategoryIndex == index
                            let category = categories[index]
                            if isSelected {
                                Text(category.title)
                                    .gilroySemiBold(15)
                                    .padding(.horizontal, 10)
                                    .frame(height: 40)
                                    .background(.black)
                                    .cornerRadius(5)
                                    .foreColor(.white)
                                    .id(index)
                            } else {
                                Text(category.title)
                                    .gilroyRegular(15)
                                    .padding(.horizontal, 10)
                                    .frame(height: 40)
                                    .background(.white)
                                    .cornerRadius(5)
                                    .foreColor(currentCategoryIndex == index ? .white : .black)
                                    .id(index)
                                    .onTapGesture {
                                        currentCategoryIndex = index
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .onChange(of: currentCategoryIndex) { _ in
                        withAnimation {
                            proxy.scrollTo(currentCategoryIndex, anchor: .center)
                        }
                    }
                }
            }
            .frame(height: 56)
           
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading) {
                        LazyVGrid(columns: [.init(spacing: Const.itemSpacing), .init()],alignment: .center, spacing: Const.itemSpacing, content: {
                            if currentCategoryIndex < categories.count {
                                let category = categories[currentCategoryIndex]
                                let articles = self.articles.filter({ $0.categoryID == category.id })
                                ForEach(articles, id: \.id) { item in
                                    discoveryItemView(item)
                                        .onTapGesture {
                                            viewModel.input.selectArticle.onNext(item)
                                        }
                                }
                            }
                        })
                    }
                }
                .padding(Const.horizontalPadding)
            }
        }
        .onAppear {
            let categoryURL = Bundle.main.url(forResource: "ArticleCategory", withExtension: "json")!
            let itemURL = Bundle.main.url(forResource: "ListArticle", withExtension: "json")!
            let decoder = JSONDecoder()
            
            do {
                let categorydata = try Data(contentsOf: categoryURL)
                let itemdata = try Data(contentsOf: itemURL)

                
                self.articles = try decoder.decode([Article].self, from: itemdata)
                
                self.categories = try decoder.decode([ArticleCategory].self, from: categorydata).filter({ category in  self.articles.contains(where: { $0.categoryID == category.id})})
            } catch {
                print(error)
            }
        }
    }
    
    func discoveryItemView(_ item: Article) -> some View {
        VStack(alignment: .leading,spacing: 10) {
            AsyncImage(url: URL(string: item.image)) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color("Gray02")
                        ProgressView().circleprogressColor(Color("Secondary"))
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Color.gray
                }
            }
            .frame(width: Const.itemWidth, height: Const.itemHeight)
            .cornerRadius(Const.itemCorner)
            
            Text(item.title)
                .gilroyRegular(15)
                .lineLimit(2)
        }
    }
}

#Preview {
    HomeView(viewModel: .init())
}
