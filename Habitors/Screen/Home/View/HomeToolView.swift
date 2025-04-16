//
//  HomeProfileView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 14/3/25.
//

import SwiftUI
import SakuraExtension
import RxSwift

enum Tool: String, CaseIterable {
    case relaxingMusic = "Relaxing Music"
    case natureSounds = "Nature Sounds"
    case meditativeMusic = "Meditative Music"
    case soundscapeMusic = "Soundscape Music"
    
    case moodRecorder
    case note
    
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
        case .moodRecorder:
            Image("tool_mood")
        case .note:
            Image("tool_note")
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
    var namespace: Namespace.ID
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(spacing: Const.itemSpacing)], spacing: Const.itemSpacing) {
                HStack(spacing: Const.itemSpacing) {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading) {
                            Text("Moodie")
                                .gilroyBold(16)
                            
                            Text("Tap to record")
                                .gilroyRegular(12)
                        }
                        
                        Spacer(minLength: 0)
                        
                        Text("🤔")
                            .font(.system(size: 30))
                    }
                    .padding(20)
                    .background(Color("Secondary").opacity(0.2))
                    .cornerRadius(10, corners: .allCorners)
                    .onTapGesture {
                        viewModel.routing.routeToMoodie.onNext(())
                    }
                    
                    HStack(spacing: 0) {
                        VStack(alignment: .leading) {
                            Text("Quick Note")
                                .gilroyBold(16)
                            
                            Text("Tap to add")
                                .gilroyRegular(12)
                        }
                        
                        Spacer(minLength: 0)
                        
                        Text("📝")
                            .font(.system(size: 30))
                    }
                    .padding(20)
                    .background(Color("Warning").opacity(0.1))
                    .cornerRadius(10, corners: .allCorners)
                }
                
                
                GroupItemView(tools: [
                    .relaxingMusic,
                    .natureSounds,
                    .meditativeMusic,
                    .soundscapeMusic
                ])
            }
            .padding(.horizontal, Const.horizontalPadding)
        }
    }
}

// MARK: - GroupItemView
fileprivate struct GroupItemView: View {
    var tools: [Tool]
    
    var body: some View {
        HStack(spacing: Const.itemSpacing) {
            VStack(spacing: Const.itemSpacing) {
                if tools.count > 0 {
                    ToolItemView(index: 0, tool: tools[0])
                } else {
                    Spacer(minLength: 0)
                }
                
                if tools.count > 2 {
                    ToolItemView(index: 2, tool: tools[2])
                } else {
                    Spacer(minLength: 0)
                }
            }
            
            VStack(spacing: Const.itemSpacing) {
                if tools.count > 1 {
                    ToolItemView(index: 1, tool: tools[1])
                } else {
                    Spacer(minLength: 0)
                }
                
                if tools.count > 3 {
                    ToolItemView(index: 3, tool: tools[3])
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

fileprivate struct ToolItemView: View {
    var index: Int = 0
    var tool: Tool
    var isHeightEqualWidth: Bool = false
    
    var body: some View {
        tool.thumbnail.resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .cornerRadius(10)
            .clipped()
            .overlay(
                ZStack(alignment: .bottomLeading) {
                    Color.clear
                    Text(tool.rawValue)
                        .gilroyBold(18)
                        .foreColor(.white)
                        .padding(10)
                }
            )
    }
    
    var width: CGFloat {
        Const.itemWidth
    }
    
    var height: CGFloat {
        if isHeightEqualWidth {
            return width
        }
        
        return index % 4 == 0 || index % 4 == 3 ? Const.oddItemHeight : Const.evenItemHeight
    }
}

#Preview {
    HomeView(viewModel: .init())
}
