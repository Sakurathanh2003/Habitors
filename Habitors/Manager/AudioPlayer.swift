//
//  AudioPlayer.swift
//  Habitors
//
//  Created by Thanh Vu on 22/4/25.
//
import UIKit
import Foundation
import SwiftUI
import AVFoundation
import MediaPlayer

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayer()
    private var player = AVAudioPlayer()
    
    @Published var isPlaying: Bool = false
    @Published var currentURL: URL?
    @Published var progress: CGFloat = 0
    private var timer: Timer?
    
    override init() {
        super.init()
        configMPRemoteCommandCenter()
    }
    
    func play(_ url: URL) {
        do {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try? AVAudioSession.sharedInstance().setActive(true)
            
            if currentURL == url {
                self.player.play()
            } else {
                self.player = try AVAudioPlayer(contentsOf: url)
                self.player.delegate = self
                self.player.play()
                self.currentURL = url
            }
            
            self.isPlaying = true
            self.startTimer()
            self.setupNowPlaying(title: url.deletingPathExtension().lastPathComponent, duration: player.duration)
        } catch {
            print("Error: \(error)")
            self.isPlaying = false
        }
    }
    
    @objc func pause() {
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
    
    // MARK: - MPRemoteCommandCenter
    private func setupNowPlaying(title: String, duration: TimeInterval) {
        var nowPlayingInfo : [String : AnyObject] = [
            MPMediaItemPropertyPlaybackDuration : duration as AnyObject,
            MPMediaItemPropertyTitle            : title as AnyObject,
            MPNowPlayingInfoPropertyElapsedPlaybackTime : player.duration * progress as AnyObject,
            MPNowPlayingInfoPropertyPlaybackQueueCount  : 1 as AnyObject,
            MPNowPlayingInfoPropertyPlaybackQueueIndex  : 1 as AnyObject,
            MPMediaItemPropertyMediaType : MPMediaType.anyAudio.rawValue as AnyObject,
        ]
        
        if let image = UIImage(named: title) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    private func configMPRemoteCommandCenter() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        addActionToPauseCommnd()
        addActionToPlayCommnd()
    }
    
    private func addActionToPauseCommnd(){
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [unowned self] event in
            self.pause()
            return .success
        }
    }
    
    private func addActionToPlayCommnd(){
        MPRemoteCommandCenter.shared().playCommand.addTarget { [unowned self] event in
            if let currentURL {
                self.play(currentURL)
            }
            
            return .success
        }
    }
}
