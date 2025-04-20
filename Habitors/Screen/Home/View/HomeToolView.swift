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
    var namespace: Namespace.ID
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(spacing: Const.itemSpacing)], spacing: Const.itemSpacing) {
                HStack(spacing: Const.itemSpacing) {
                    
                    
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
                    .onTapGesture {
                        viewModel.routing.routeToQuickNote.onNext(())
                    }
                }
                
                GroupItemView(animation: namespace, tools: [
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
        }
    }
}

// MARK: - GroupItemView
fileprivate struct GroupItemView: View {
    var animation: Namespace.ID
    var tools: [Tool]
    var selectTool: (Tool) -> Void
    
    var body: some View {
        HStack(spacing: Const.itemSpacing) {
            VStack(spacing: Const.itemSpacing) {
                if tools.count > 0 {
                    ToolItemView(animation: animation, index: 0, tool: tools[0])
                        .onTapGesture {
                            selectTool(tools[0])
                        }
                } else {
                    Spacer(minLength: 0)
                }
                
                if tools.count > 2 {
                    ToolItemView(animation: animation, index: 2, tool: tools[2])
                        .onTapGesture {
                            selectTool(tools[2])
                        }
                } else {
                    Spacer(minLength: 0)
                }
            }
            
            VStack(spacing: Const.itemSpacing) {
                if tools.count > 1 {
                    ToolItemView(animation: animation, index: 1, tool: tools[1])
                        .onTapGesture {
                            selectTool(tools[1])
                        }
                } else {
                    Spacer(minLength: 0)
                }
                
                if tools.count > 3 {
                    ToolItemView(animation: animation, index: 3, tool: tools[3])
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

// MARK: - Audio Player
class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayer()
    private var player = AVAudioPlayer()
    
    @Published var isPlaying: Bool = false
    @Published var currentURL: URL?
    @Published var progress: CGFloat = 0
    private var timer: Timer?
    
    func play(_ url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            if currentURL == url {
                self.player.play()
                self.isPlaying = true
                startTimer()
                return
            }
            
            self.player = try AVAudioPlayer(contentsOf: url)
            self.player.delegate = self
            self.player.play()
            self.currentURL = url
            self.isPlaying = true
            startTimer()
        } catch {
            print("Error: \(error)")
            self.isPlaying = false
        }
    }
    
    func pause() {
        self.isPlaying = false
        self.player.pause()
        stopTimer()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.isPlaying = false
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        self.pause()
    }
    
    func getItem() -> String? {
        return currentURL?.deletingPathExtension().lastPathComponent
    }
    
    func startTimer() {
        stopTimer() // Xoá timer cũ nếu có
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] _ in
            self.progress = player.currentTime / player.duration
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func seek(to value: Double) {
        player.currentTime = value * player.duration
    }
    
    func forward(seconds: TimeInterval = 15) {
        let newTime = min(player.currentTime + seconds, player.duration)
        player.currentTime = newTime
    }
    
    func rewind(seconds: TimeInterval = 15) {
        let newTime = max(player.currentTime - seconds, 0)
        player.currentTime = newTime
    }
}

struct ToolItemView: View {
    var animation: Namespace.ID
    var index: Int = 0
    var tool: Tool
    var isOpening: Bool = false
    var closeAction: (() -> Void)?
    
    @ObservedObject var player: AudioPlayer = .shared
    @State var isAudioOpening: Bool = false
    
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
                        Text(tool.rawValue)
                            .gilroyBold(30)
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
                                        .gilroyRegular(16)
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
                        Text(tool.rawValue)
                            .gilroyBold(18)
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

                    Spacer()
                }.padding(.leading, 20)
                
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
                .padding(.vertical, 50)
                
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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let image = self.body.snapshot()
                    let brightness = image.averageBrightness()
                    self.iconColor = brightness < 0.5 ? .white : .black
                }
            }
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
                
                Text(name).gilroyRegular(16)
                
                Spacer()
                
                if player.isPlaying {
                    Image(systemName: "pause")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            player.pause()
                        }
                } else {
                    Image(systemName: "play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            player.play(Bundle.main.url(forResource: item, withExtension: "mp3")!)
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white.ignoresSafeArea())
            .overlay(
                VStack {
                    GeometryReader { proxy in
                        Color("Primary").frame(width: proxy.size.width * player.progress)
                    }.frame(height: 2)
                   
                    Spacer()
                }
            )
        }
    }
    
    var name: String {
        item.capitalized.replacingOccurrences(of: "_", with: " ")
    }
}

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
    ToolItemView(animation: Namespace().wrappedValue,
                 tool: Tool.soundscapeMusic,
                 isOpening: true)
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}

extension UIImage {
    func averageBrightness() -> CGFloat {
        guard let cgImage = self.cgImage else { return 1 }
        let ciImage = CIImage(cgImage: cgImage)
        let extent = ciImage.extent

        let context = CIContext()
        let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: extent)
        ])!

        guard let outputImage = filter.outputImage else { return 1 }
        var bitmap = [UInt8](repeating: 0, count: 4)

        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())

        let r = CGFloat(bitmap[0]) / 255
        let g = CGFloat(bitmap[1]) / 255
        let b = CGFloat(bitmap[2]) / 255

        return 0.299 * r + 0.587 * g + 0.114 * b
    }
}

