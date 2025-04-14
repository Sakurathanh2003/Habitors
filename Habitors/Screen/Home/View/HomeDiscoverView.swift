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
                                
                                ForEach(category.items, id: \.id) { item in
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
            let url = Bundle.main.url(forResource: "discoveryData", withExtension: "json")!
            let decoder = JSONDecoder()
            
            do {
                let data = try Data(contentsOf: url)
                let categories = try decoder.decode([ArticleCategory].self, from: data)
                self.categories = categories
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
    ArticleDetailView(item: .init(id: "0", image: "https://img.freepik.com/free-vector/world-health-day-background_23-2147783361.jpg?t=st=1744649560~exp=1744653160~hmac=7cd4f4863630d5c118b7d995f548987e1358c0c5311c6a69114c3ccc41f8096e&w=1380", title: "A healthy morning start-pack", content: "A Healthy Morning Start-pack: How to Do it Right!\n\nYour morning routine will determine the tone of your day, so it’s time to start planning accordingly. When you form healthy  behaviours of the morning, you set your day up for success. Here are some healthy ways to start your morning:\n\n🧘🏻‍♂️Meditate\nIncorporating some type of mindfulness practice like meditation into your daily morning routine can help ground you and train your mind and emotions, which then influences how you react to challenges throughout your day.\n\n🛌Make your bed\nIt may seem like a waste of time, or unnecessary but making your bed is a simple action you can take in the morning that makes you start your day feeling accomplished.\n\n🏃🏻‍♀️Move your body\nWhether it’s a brisk walk with your pet, a simple yoga routine, a set of push-ups and sit-ups, or hitting the gym, starting your day with stretching energizes your mind and body for the day ahead.\n\n🍳Eat a nutritious breakfast\nThere’s no one universally good breakfas: It depends on your nutrition goals, preferences, and morning schedule. It also depends on how naturally hungry your are in the morning. If you can’t focus on an empty stomach, a simple breakfast you can prepare ahead of time (like overnight oats or egg white bites) will be key to starting your day.\n\n🌦️Check weather\nBefore starting your day, it’s helpful to know what weather conditions to expect. This can influence your clothing choices and plans for outdoor activities.\n\n📝Review your to-do list\nTake a moment to review your to-do list for the day. This helps you prioritize tasks, allocate time effectively, and mentally prepare for what’s ahead.\n\nTry using the above methods to change your otherwise chaotic morning. A good morning can brighten your day!", habits: [
        .init(icon: "🧘🏻‍♂️", name: "Meditate"),
        .init(icon: "🛌", name: "Make your bed"),
        .init(icon: "🏃🏻‍♀️", name: "Move your body"),
        .init(icon: "🍳", name: "Eat a nutritious breakfast"),
        .init(icon: "🌦️", name: "Check weather"),
        .init(icon: "📝", name: "Review your to-do list")
    ]))
  //  HomeView(viewModel: .init())
}
