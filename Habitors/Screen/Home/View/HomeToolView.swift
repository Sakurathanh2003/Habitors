//
//  HomeProfileView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 14/3/25.
//

import SwiftUI
import SakuraExtension
import RxSwift
import AVFoundation
import SeekBar

enum Tool: String, CaseIterable {
    case relaxingMusic = "Relaxing Music"
    case natureSounds = "Nature Sounds"
    case meditativeMusic = "Meditative Music"
    case soundscapeMusic = "Soundscape Music"
    
    var thumbnail: Image {
        switch self {
        case .relaxingMusic:
            Image("tool_relax_music")
        case .natureSounds:
            Image("tool_natural_sound")
        case .meditativeMusic:
            Image("tool_meditative_music")
        case .soundscapeMusic:
            Image("tool_soundscape_music")
        }
    }
}

fileprivate struct Const {
    static let horizontalPadding: CGFloat = 20.0
    
    static let itemSpacing = 20.0
    static let itemWidth = (UIScreen.main.bounds.width - horizontalPadding * 2 - itemSpacing) / 2
    static let oddItemHeight = itemWidth * 1.5
    static let evenItemHeight = itemWidth * 1.2
}

struct HomeToolView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var mood = Mood.allCases.randomElement()
    var namespace: Namespace.ID
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(spacing: Const.itemSpacing)], spacing: Const.itemSpacing) {
                if let mood {
                    HStack {
                        Image("icon_\(mood.rawValue)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("How do you feel?")
                                .fontSemiBold(16)
                            
                            Text("Tap to record")
                                .fontRegular(12)
                                .foreColor(.black.opacity(0.8))
                        }
                    }
                    .padding(20)
                    .background(mood.color.opacity(0.6))
                    .background(.white)
                    .cornerRadius(5, corners: .allCorners)
                    .onTapGesture {
                        viewModel.routing.routeToMoodie.onNext(())
                    }
                }
                
                HStack(spacing: Const.itemSpacing) {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading) {
                            Text("Quick Note")
                                .fontBold(16)
                            
                            Text("Tap to add")
                                .fontRegular(12)
                        }
                        
                        Spacer(minLength: 0)
                        
                        Text("📝")
                            .font(.system(size: 30))
                    }
                    .padding(20)
                    .background(Color("Warning").opacity(0.1))
                    .background(.white)
                    .cornerRadius(10, corners: .allCorners)
                    .onTapGesture {
                        viewModel.routing.routeToQuickNote.onNext(())
                    }
                }
                
                GroupItemView(viewModel: viewModel, animation: namespace, tools: [
                    .relaxingMusic,
                    .natureSounds,
                    .meditativeMusic,
                    .soundscapeMusic
                ], selectTool: { tool in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        viewModel.currentTool = tool
                    }
                })
            }
            .padding(.horizontal, Const.horizontalPadding)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - GroupItemView
fileprivate struct GroupItemView: View {
    @ObservedObject var viewModel: HomeViewModel
    var animation: Namespace.ID
    var tools: [Tool]
    var selectTool: (Tool) -> Void
    
    var body: some View {
        HStack(spacing: Const.itemSpacing) {
            VStack(spacing: Const.itemSpacing) {
                if tools.count > 0 {
                    ToolItemView(viewModel: viewModel, animation: animation, index: 0, tool: tools[0])
                        .onTapGesture {
                            selectTool(tools[0])
                        }
                } else {
                    Spacer(minLength: 0)
                }
                
                if tools.count > 2 {
                    ToolItemView(viewModel: viewModel, animation: animation, index: 2, tool: tools[2])
                        .onTapGesture {
                            selectTool(tools[2])
                        }
                } else {
                    Spacer(minLength: 0)
                }
            }
            
            VStack(spacing: Const.itemSpacing) {
                if tools.count > 1 {
                    ToolItemView(viewModel: viewModel, animation: animation, index: 1, tool: tools[1])
                        .onTapGesture {
                            selectTool(tools[1])
                        }
                } else {
                    Spacer(minLength: 0)
                }
                
                if tools.count > 3 {
                    ToolItemView(viewModel: viewModel, animation: animation, index: 3, tool: tools[3])
                        .onTapGesture {
                            selectTool(tools[3])
                        }
                } else {
                    Spacer(minLength: 0)
                }
            }
            
            if tools.count == 1 {
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - ToolItemView
struct ToolItemView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var player: AudioPlayer = .shared
    @State var isAudioOpening: Bool = false
    
    var animation: Namespace.ID
    var index: Int = 0
    var tool: Tool
    var isOpening: Bool = false
    var closeAction: (() -> Void)?
    
    @ViewBuilder
    var body: some View {
        if isOpening {
            ScrollView {
                VStack(alignment: .leading) {
                    Image(systemName: "multiply")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                closeAction?()
                            }
                        }
                        .padding(.leading, 20)
                    
                    VStack(alignment: .leading) {
                        Text(viewModel.translate(tool.rawValue))
                            .fontBold(30)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 60)
                           
                        
                        ForEach(tool.items.indices, id: \.self) { index in
                            let item = tool.items[index]
                            let name = item.capitalized.replacingOccurrences(of: "_", with: " ")
                            
                            Button {
                                player.play(Bundle.main.url(forResource: item, withExtension: "mp3")!)
                            } label: {
                                HStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        Text("\(index + 1)")
                                        Spacer(minLength: 0)
                                    }.frame(width: 30)
                                    
                                    Image(item)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipped()
                                        .cornerRadius(5)
                                    
                                    Text(name)
                                        .fontRegular(16)
                                        .padding(.leading, 15)
                                    
                                    Spacer(minLength: 0)
                                }
                                .padding(.horizontal, 20)
                                .frame(height: 56)
                            }
                        }
                    }
                    .padding(.vertical, UIScreen.main.bounds.width / 2)
                }
                .foregroundStyle(.white)
            }
            .background(
                LinearGradient(stops: [
                    .init(color: .black.opacity(0), location: 0),
                    .init(color: .black.opacity(1), location: 0.5)
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            )
            .background(alignment: .top, content: {
                VStack {
                    tool.thumbnail
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    Color.clear
                }.ignoresSafeArea()
            })
            .background(Color.black.ignoresSafeArea() )
            .overlay(
                ZStack(alignment: .bottom) {
                    if let currentItem = player.getItem() {
                        if isAudioOpening {
                            AudioView(player: player, item: currentItem, isOpen: $isAudioOpening)
                                .matchedGeometryEffect(id: "audioplayer", in: animation)
                        } else {
                            Color.clear
                            AudioView(player: player, item: currentItem, isOpen: $isAudioOpening)
                                .matchedGeometryEffect(id: "audioplayer", in: animation)
                                .onTapGesture {
                                    withAnimation {
                                        isAudioOpening = true
                                    }
                                }
                        }
                    }
                }
            )
            .matchedGeometryEffect(id: tool.rawValue, in: animation)
        } else {
            tool.thumbnail.resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .cornerRadius(10)
                .clipped()
                .overlay(
                    ZStack(alignment: .bottomLeading) {
                        Color.clear
                        Text(viewModel.translate(tool.rawValue))
                            .fontBold(18)
                            .foreColor(.white)
                            .padding(10)
                    }
                )
                .matchedGeometryEffect(id: tool.rawValue, in: animation)
        }
    }
    
    var width: CGFloat {
        Const.itemWidth
    }
    
    var height: CGFloat {
        return index % 4 == 0 || index % 4 == 3 ? Const.oddItemHeight : Const.evenItemHeight
    }
}

// MARK: - AudioView


extension Tool {
    var items: [String] {
        return switch self {
        case .relaxingMusic:
            [
                "flying",
                "the_hidden_valley"
            ]
        case .natureSounds:
            [
                "autumn_breeze",
                "sailing_the_harbor"
            ]
        case .meditativeMusic:
            [
                "a_golden_morning",
                "breath_cycle",
                "energy_ball",
                "hair_dryer",
                "laringeal",
                "mindfulness"
            ]
        case .soundscapeMusic:
            [
                "percussion",
                "rain_and_thunder",
                "river"
            ]
        }
    }
}

#Preview {
    HomeView(viewModel: .init())
}
