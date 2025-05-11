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



struct MoodieView: View {
    @ObservedObject var viewModel: MoodieViewModel
    @State var location: CGSize = .zero
    
    @State var offset: [CGSize] = Array(repeating: .zero, count: 6)
    @State var zIndex: [Int] = [5, 4, 3, 2, 1, 0]
    @Namespace var animation
    
    var currentMood: Mood {
        return viewModel.mood(of: viewModel.currentIndex)
    }
    
    var body: some View {
        ZStack {
            currentMood.color.opacity(0.4).ignoresSafeArea()
                .animation(.default, value: viewModel.currentIndex)
            
            VStack {
                ZStack {
                    ForEach(viewModel.moods.indices, id: \.self) { index in
                        let mood = viewModel.mood(of: index)
                        
                        MoodCardView(choosedMood: $viewModel.addSuccessMood,
                                     animation: animation,
                                     mood: mood)
                            .zIndex(Double(zIndex[index]))
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
                                            viewModel.currentIndex = (index + 1) % Mood.allCases.count
                                            
                                            for i in 0..<6 {
                                                zIndex[i] = (zIndex[i] + 1) % zIndex.count
                                            }
                                            
                                            offset = Array(repeating: .zero, count: 6)
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
                            .fontBold(16)
                            .foreColor(.white)
                    )
                    .cornerRadius(56, corners: .allCorners)
                    .onTapGesture {
                        viewModel.input.selectMood.onNext(())
                    }
                    .padding(20)
            }
            
            if let mood = viewModel.addSuccessMood {
                ZStack {
                    Color.clear
                    VStack {
                        Spacer(minLength: 0)
                        Image("\(mood.rawValue)_\(mood.thumbnailCount)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .matchedGeometryEffect(id: "mood_\(mood.rawValue)_thumbnail", in: animation)
                        
                        Spacer(minLength: 0)
                        
                        Text("We've Recorded Your Mood")
                            .matchedGeometryEffect(id: "mood_\(mood.rawValue)_question", in: animation)
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("We've recorded your emotional state.\nOur goal is to provide you with tailored support to enhance your well-being and productivity.")
                            .multilineTextAlignment(.center)
                        
                        Spacer(minLength: 0)
                        
                        Color.black.frame(height: 56)
                            .overlay(
                                Text("View Mode History")
                                    .fontBold(16)
                                    .foreColor(.white)
                            )
                            .cornerRadius(56, corners: .allCorners)
                            .onTapGesture {
                                viewModel.routing.history.onNext(true)
                            }
                            .padding(20)
                        
                        Spacer(minLength: 0)
                    }.padding(20)
                }.zIndex(1)
                    .background(
                        mood.color
                            .matchedGeometryEffect(id: "mood_\(mood.rawValue)_background", in: animation)
                            .ignoresSafeArea()
                    )
                
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
            
            Image("history")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .onTapGesture {
                    viewModel.routing.history.onNext(false)
                }
        }
        .frame(height: 56)
    }
}

// MARK: -  MoodCardView
struct MoodCardView: View {
    @Binding var choosedMood: Mood?
    var animation: Namespace.ID
    var mood: Mood
    
    var body: some View {
        ZStack {
            if mood != choosedMood {
                mood.color
                    .matchedGeometryEffect(id: "mood_\(mood.rawValue)_background", in: animation)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                if mood != choosedMood {
                    Text("How are you feeling today?")
                        .matchedGeometryEffect(id: "mood_\(mood.rawValue)_question", in: animation)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.top, 48)
                }
                
                Text(mood.rawValue.capitalized)
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .padding(.top, 20)
                
                if mood != choosedMood {
                    Image("\(mood.rawValue)_\(mood.thumbnailCount)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: "mood_\(mood.rawValue)_thumbnail", in: animation)
                }
            }
        }
        .cornerRadius(24, corners: .allCorners)
        .frame(width: width, height: height)
    }
    
    var width: CGFloat {
        UIScreen.main.bounds.width - 20 * 2
    }
    
    var height: CGFloat {
        width / 335 * 411
    }
}
#Preview {
    MoodieView(viewModel: MoodieViewModel())
}
