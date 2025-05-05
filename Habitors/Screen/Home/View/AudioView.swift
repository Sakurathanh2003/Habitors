//
//  AudioView.swift
//  Habitors
//
//  Created by Thanh Vu on 30/4/25.
//
import RxSwift
import SwiftUI
import SeekBar
import SakuraExtension

struct AudioView: View {
    @ObservedObject var player: AudioPlayer
    var item: String
    @Binding var isOpen: Bool
    @State private var iconColor: Color = .white
    @State private var isRotating = false
    
    @ViewBuilder
    var body: some View {
        if isOpen {
            VStack(spacing: 0) {
                HStack {
                    Text(name).fontBold(28)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isOpen = false
                        }
                    } label: {
                        Image("ic_arrow_down")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundStyle(iconColor)
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 56)
                
                Image(item)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                
                SeekBar(value: $player.progress) { isEditing in
                    player.pause()
                    if isEditing {
                        player.pause()
                    } else {
                        player.seek(to: Double(player.progress))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                HStack {
                    Text(player.currentTime)
                        .fontRegular(12)
                    
                    Spacer()
                    
                    Text(player.durationTime)
                        .fontRegular(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
                .padding(.top, 10)
                .foreColor(.white)
                
                HStack(spacing: 20) {
                    Image(systemName: "gobackward.15")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundStyle(iconColor)
                        .onTapGesture {
                            player.rewind()
                        }
                    
                    Circle()
                        .fill(.white)
                        .frame(width: 50, height: 50)
                        .overlay(
                            ZStack {
                                if player.isPlaying {
                                    Image(systemName: "pause.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            }.foregroundStyle(.black)
                        ).onTapGesture {
                            if player.isPlaying {
                                player.pause()
                            } else {
                                player.play(Bundle.main.url(forResource: item, withExtension: "mp3")!)
                            }
                        }
                    
                    Image(systemName: "goforward.15")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundStyle(iconColor)
                        .onTapGesture {
                            player.forward()
                        }
                }
                
                Spacer(minLength: 0)
            }
            .background(
                Image(item)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .blur(radius: 10)
            )
        } else {
            HStack(spacing: 20) {
                Image(item)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(25, corners: .allCorners)
                    .rotationEffect(.degrees(isRotating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 5)
                            .repeatForever(autoreverses: false),
                        value: isRotating
                    )
                    .onAppear {
                        isRotating = true
                    }
                
                Text(name)
                    .fontBold(16)
                
                Spacer()
                
                
                ZStack {
                    Circle()
                        .stroke(Color("Gray03"), lineWidth: 3)
                    
                    Circle()
                        .trim(from: 0, to: player.progress)
                        .stroke(Color("Primary"), lineWidth: 3)
                        .rotationEffect(.degrees(-90))
                    
                    Image(player.isPlaying ? "pause" : "play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(10)
                }
                .frame(width: 40, height: 40)
                .onTapGesture {
                    if player.isPlaying {
                        player.pause()
                    } else {
                        player.play(Bundle.main.url(forResource: item, withExtension: "mp3")!)
                    }
                    
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                BlurSwiftUIView(effect: .init(style: .extraLight))
                    .ignoresSafeArea()
            )
            .frame(height: 66)
            .cornerRadius(33)
            .overlay(
                RoundedRectangle(cornerRadius: 33)
                    .stroke(.gray, lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
    
    var name: String {
        item.capitalized.replacingOccurrences(of: "_", with: " ")
    }
}

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()
        
        AudioView(player: .shared, item: "a_golden_morning", isOpen: .constant(true))
    }
}
