//
//  ArticleDetailView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/4/25.
//
import SwiftUI
import SakuraExtension
import RxSwift

fileprivate struct AddHabitView: View {
    @Binding var isTurnDarkMode: Bool
    @Binding var isPresenting: Bool
    @Binding var selectedHabit: [Article.Habit]

    var habits: [Article.Habit]
    
    var saveAction: (() -> Void)
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationBarView(title: "Edit Routine", isDarkMode: isTurnDarkMode) {
                withAnimation {
                    isPresenting = false
                }
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(habits.indices, id: \.self) { index in
                        let habit = habits[index]
                        HStack {
                            Text("\(index + 1).")
                                .fontBold(16)
                                .foreColor(mainColor)
                                .frame(width: 20)
                               
                            Text(habit.icon + " " + habit.name)
                                .fontBold(16)
                                .foreColor(mainColor)
                            
                            Spacer(minLength: 10)
                            
                            if selectedHabit.contains(where: { $0.icon == habit.icon }) {
                                Circle()
                                    .fill(mainColor)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .renderingMode(.template)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .padding(1)
                                            .foregroundStyle(backgroundColor)
                                            .frame(width: 10, height: 10)
                                    )
                                    .padding(1)
                                    .frame(width: 24, height: 24)
                            } else {
                                Circle()
                                    .stroke(mainColor, lineWidth: 1)
                                    .padding(1)
                                    .frame(width: 24, height: 24)
                            }
                            
                        }
                        .frame(minHeight: 56)
                        .background(backgroundColor)
                        .padding(10)
                        .onTapGesture {
                            if let index = selectedHabit.firstIndex(where: { $0.icon == habit.icon}) {
                                selectedHabit.remove(at: index)
                            } else {
                                selectedHabit.append(habit)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .background(backgroundColor.ignoresSafeArea())
        .overlay(
            VStack {
                Spacer()
                
                mainColor.frame(height: 56)
                    .overlay(
                        Text("Save")
                            .fontBold(16)
                            .foreColor(backgroundColor)
                    )
                    .cornerRadius(10)
                    .onTapGesture(perform: {
                        saveAction()
                    })
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .background(
                        LinearGradient(colors: [
                            .clear, backgroundColor
                        ], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                    )
            }
        )
        .offset(y: isPresenting ? 0 : UIScreen.main.bounds.height)
    }
    
    var backgroundColor: Color {
        return isTurnDarkMode ? .black : .white
    }
    
    var mainColor: Color {
        return isTurnDarkMode ? .white : .black
    }
}

struct ArticleDetailView: View {
    @ObservedObject var viewModel: DetailArticleViewModel
    @State private var isAnimating: Bool = false
        
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationBarView(title: "Article", isDarkMode: viewModel.isTurnDarkMode) {
                viewModel.routing.stop.onNext(())
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    thumbnailView
                    
                    Text(viewModel.item.title)
                        .fontBold(23)
                        .foreColor(mainColor)
                    
                    Text(viewModel.item.content)
                        .fontRegular(16)
                        .lineSpacing(6)
                        .foreColor(mainColor)
                }
                .padding(.bottom, 100)
            }
        }
        .padding(.horizontal, 20)
        .overlay(
            VStack {
                Spacer()
                
                if !viewModel.item.habits.isEmpty {
                    let scale = isAnimating ? 1.1 : 1
                    
                    mainColor.frame(height: 56)
                        .overlay(
                            Text("Add to my routine")
                                .fontBold(16)
                                .foreColor(backgroundColor)
                        )
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .scaleEffect(x: scale, y: scale)
                        .animation(.easeInOut.repeatForever(), value: isAnimating)
                        .onTapGesture {
                            viewModel.selectedHabit = viewModel.item.habits
                            withAnimation {
                                viewModel.isEditingRoutine = true
                            }
                        }
                        .padding(.top, 20)
                        .background(
                            LinearGradient(colors: [
                                .clear, backgroundColor
                            ], startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea()
                        )
                }
            }
        )
        .overlay(
            AddHabitView(
                isTurnDarkMode: $viewModel.isTurnDarkMode,
                isPresenting: $viewModel.isEditingRoutine,
                selectedHabit: $viewModel.selectedHabit,
                habits: viewModel.item.habits,
                saveAction: {
                    viewModel.input.didTapSave.onNext(())
                })
        )
        .background(backgroundColor.ignoresSafeArea())
        .onAppear {
            isAnimating = true
        }
        .statusBarHidden()
        .navigationBarBackButtonHidden()
    }
    
    var thumbnailView: some View {
        AsyncImage(url: URL(string: viewModel.item.image)) { phase in
            switch phase {
            case .empty:
                ProgressView().circleprogressColor(Color("Secondary"))
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
            default:
                ProgressView().circleprogressColor(Color("Secondary"))
            }
        }
    }
}

// MARK: - Get
extension ArticleDetailView {
    var backgroundColor: Color {
        return viewModel.isTurnDarkMode ? .black : .white
    }
    
    var mainColor: Color {
        return viewModel.isTurnDarkMode ? .white : .black
    }
}

#Preview {
    ArticleDetailView(viewModel: DetailArticleViewModel(item: .init(id: "0", categoryID: "0", image: "https://img.freepik.com/free-vector/world-health-day-background_23-2147783361.jpg?t=st=1744649560~exp=1744653160~hmac=7cd4f4863630d5c118b7d995f548987e1358c0c5311c6a69114c3ccc41f8096e&w=1380", title: "A healthy morning start-pack", content: "A Healthy Morning Start-pack: How to Do it Right!\n\nYour morning routine will determine the tone of your day, so it’s time to start planning accordingly. When you form healthy  behaviours of the morning, you set your day up for success. Here are some healthy ways to start your morning:\n\n🧘🏻‍♂️Meditate\nIncorporating some type of mindfulness practice like meditation into your daily morning routine can help ground you and train your mind and emotions, which then influences how you react to challenges throughout your day.\n\n🛌Make your bed\nIt may seem like a waste of time, or unnecessary but making your bed is a simple action you can take in the morning that makes you start your day feeling accomplished.\n\n🏃🏻‍♀️Move your body\nWhether it’s a brisk walk with your pet, a simple yoga routine, a set of push-ups and sit-ups, or hitting the gym, starting your day with stretching energizes your mind and body for the day ahead.\n\n🍳Eat a nutritious breakfast\nThere’s no one universally good breakfas: It depends on your nutrition goals, preferences, and morning schedule. It also depends on how naturally hungry your are in the morning. If you can’t focus on an empty stomach, a simple breakfast you can prepare ahead of time (like overnight oats or egg white bites) will be key to starting your day.\n\n🌦️Check weather\nBefore starting your day, it’s helpful to know what weather conditions to expect. This can influence your clothing choices and plans for outdoor activities.\n\n📝Review your to-do list\nTake a moment to review your to-do list for the day. This helps you prioritize tasks, allocate time effectively, and mentally prepare for what’s ahead.\n\nTry using the above methods to change your otherwise chaotic morning. A good morning can brighten your day!", habits: [
        .init(icon: "", name: "Xin chao", unit: .count, goalValue: 1)
    ])))
}
