//
//  ViewController.swift
//  VideoPlayer
//
//  Created by Devansh Mohata on 14/08/24.
//

import AVKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var cache: VideoCache = .init()
    private var availablePlayers: [AVPlayer] = []
    private var playerDictionary: [IndexPath: AVPlayer] = [:]
    private var playerCount: Int = 5
    private var videos: [URL] = []
    private let preloadBuffer = 1 // Number of videos to preload in each direction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addVideos()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(VideoPlayerCell.self, forCellReuseIdentifier: VideoPlayerCell.identifier)
    }
    
    
    private func addVideos() {
        videos.append(URL(string: "https://www.pexels.com/video/2499611/")!)
        videos.append(URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
        videos.append(URL(string: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4")!)
        videos.append(URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!)
        videos.append(URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!)
        videos.append(URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!)
        videos.append(URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4")!)
    }
    
    private func configureCell(_ cell: VideoPlayerCell, at indexPath: IndexPath) {
        var player: AVPlayer
        
        if let existingPlayer = playerDictionary[indexPath] {
            player = existingPlayer
        } else {
            player = AVPlayer()
            playerDictionary[indexPath] = player
        }
        
        let video = videos[indexPath.row]
        
        let asset = AVURLAsset(url: video)
        let resourceLoaderDelegate = ResourceLoaderDelegate(cache: cache, url: video)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue.global(qos: .userInitiated))
        
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
        
        if let storedTime = cache.getPlaybackTime(for: video) {
            player.seek(to: storedTime)
        }
        
        cell.configure(player: player)
    }
    
    private func playVideo(at indexPath: IndexPath) {
        for (playerIndexPath, player) in playerDictionary {
            if playerIndexPath == indexPath {
                player.play()
            } else {
                player.pause()
                // Store playback time for paused videos
                let video = videos[playerIndexPath.row]
                cache.storePlaybackTime(time: player.currentTime(), for: video)
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { videos.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: VideoPlayerCell.identifier) as? VideoPlayerCell {
            configureCell(cell, at: indexPath)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { tableView.bounds.height }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let videoCell = cell as? VideoPlayerCell else { return }
        videoCell.pause()
        if let player = playerDictionary[indexPath] {
            cache.storePlaybackTime(time: player.currentTime(), for: videos[indexPath.row])
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleIndexPaths = tableView.indexPathsForVisibleRows ?? []
        guard let currentIndexPath = visibleIndexPaths.first else { return }
        
        playVideo(at: currentIndexPath)
    }
}
