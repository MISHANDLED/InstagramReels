//
//  PlayerManager.swift
//  VideoPlayer
//
//  Created by Devansh Mohata on 16/08/24.
//

import AVKit
import Foundation

final class PlayerManager {
    private var players: [AVPlayer]
    private var currentIndex: Int
    
    init() {
        self.players = (0..<3).map { _ in AVPlayer() }
        currentIndex = 1
    }
    
    func currentPlayer() -> AVPlayer {
        return players[currentIndex]
    }
    
    func preparePlayer(at offset: Int, with url: URL, cache: VideoCache, resourceLoaderDelegates: inout [URL: ResourceLoaderDelegate]) {
        let playerIndex = (currentIndex + offset + players.count) % players.count
        let player = players[playerIndex]
        
        let asset = AVURLAsset(url: url)
        if resourceLoaderDelegates[url] == nil {
            let delegate = ResourceLoaderDelegate(cache: cache, url: url)
            resourceLoaderDelegates[url] = delegate
            asset.resourceLoader.setDelegate(delegate, queue: .global(qos: .userInitiated))
        }
        
        let playerItem = AVPlayerItem(asset: asset)
        player.automaticallyWaitsToMinimizeStalling = false
        player.replaceCurrentItem(with: playerItem)
    }
    
    func advanceToNext() {
        currentIndex = (currentIndex + 1) % players.count
    }
    
    func retreatToPrevious() {
        currentIndex = (currentIndex - 1 + players.count) % players.count
    }
}
