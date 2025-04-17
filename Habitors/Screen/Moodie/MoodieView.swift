//
//  MoodieView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 16/4/25.
//

import SwiftUI
import SakuraExtension
import RxSwift
import SwiftUIIntrospect

enum Mood: String, CaseIterable {
    case angry
    case upset
    case sad
    case good
    case happy
    case spectacular
    
    var thumbnailCount: Int {
        switch self {
        case .angry: 3
        case .upset: 3
        case .sad: 3
        case .good: 3
        case .happy: 3
        case .spectacular: 4
        }
    }
    
    var color: Color {
        return Color(self.rawValue)
    }
}

struct MoodieView: View {
    @ObservedObject var viewModel: MoodieViewModel
    @State var location: CGSize = .zero
    
    @State var offset: [CGSize] = Array(repeating: .zero, count: 6)
    @State var currentIndex = 0
    
    var currentMood: Mood {
        return Mood.allCases[currentIndex]
    }

    var body: some View {
        ZStack {
            currentMood.color.opacity(0.4).ignoresSafeArea()
                .animation(.default, value: currentIndex)
            
            VStack {
                ZStack {
                    ForEach(Mood.allCases.indices, id: \.self) { index in
                        let mood = Mood.allCases[index]
                        
                        moodView(mood)
                            .zIndex(Double(currentIndex == index ? 6 : currentIndex - index))
                            .rotationEffect(.degrees(offset[index].width / 3.0))
                            .offset(offset[index])
                            .gesture(
                                DragGesture()
                                    .onChanged({ gesture in
                                        offset[index] = .init(width: location.width + gesture.translation.width,
                                                              height: abs(location.width + gesture.translation.width) / 2)
                                    })
                                    .onEnded({ gesture in
                                        offset[index] = .init(width: location.width + gesture.translation.width,
                                                              height: abs(location.width + gesture.translation.width) / 2)
                                        
                                        let isSwipeLeft = offset[index].width < 0
                                        let x = isSwipeLeft ? -UIScreen.main.bounds.width : UIScreen.main.bounds.width
                                        let y = abs(x / 2)
                                       
                                        withAnimation {
                                            offset[index] = .init(width: x * 2,
                                                                  height: y * 2)
                                            currentIndex = (index + 1) % Mood.allCases.count
                                            offset[index] = .zero
                                            offset[(currentIndex + 1) % Mood.allCases.count] = .zero
                                        }
                                    })
                            )
                    }
                }.zIndex(1)
                
                Text("Swipe to change mood")
                    .font(.system(size: 18, weight: .semibold ,design: .rounded))
                    .padding(.top, 28)
                    
                Color.black.frame(height: 56)
                    .overlay(
                        Text("Select Mood")
                            .gilroyBold(16)
                            .foreColor(.white)
                    )
                    .cornerRadius(56, corners: .allCorners)
                    .padding(20)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .overlay(
            VStack {
                navigationBar.padding(.horizontal, 20)
                Spacer()
            }
        )
    }
    
    var navigationBar: some View {
        HStack {
            Image("ic_back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .onTapGesture {
                    viewModel.routing.stop.onNext(())
                }
            
            Spacer()
        }
        .frame(height: 56)
    }
    
    func moodView(_ mood: Mood) -> some View {
        VStack(spacing: 0) {
            Text("How are you feeling today?")
                .font(.system(size: 36,weight: .bold ,design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.top, 48)
            
            Text(mood.rawValue.capitalized)
                .font(.system(size: 24,weight: .medium ,design: .rounded))
                .padding(.top, 20)
            
            Image("\(mood.rawValue)_\(mood.thumbnailCount)")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .background(mood.color)
        .cornerRadius(24, corners: .allCorners)
        .frame(width: UIScreen.main.bounds.width - 20 * 2)
    }
}

#Preview {
    MoodieView(viewModel: MoodieViewModel())
}
