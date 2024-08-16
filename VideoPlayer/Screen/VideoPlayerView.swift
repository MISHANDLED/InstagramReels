//
//  VideoPlayerView.swift
//  VideoPlayer
//
//  Created by Devansh Mohata on 16/08/24.
//

import AVKit
import UIKit

class VideoPlayerView: UIView {
    private let playerLayer = AVPlayerLayer()
    var player: AVPlayer? {
        didSet {
            playerLayer.player = player
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayerLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayerLayer()
    }

    private func setupPlayerLayer() {
        layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resizeAspect
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    func configure(with player: AVPlayer) {
        self.player = player
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func resetPlayer() {
        player?.pause()
        player = nil
    }
}
