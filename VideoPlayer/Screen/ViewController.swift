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
    private var resourceLoaderDelegates: [URL: ResourceLoaderDelegate] = [:]
    private var videos: [VideoViewModel] = []
    
    private var player: AVPlayer = AVPlayer()
    private var currentItem: AVPlayerItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        extractData()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(VideoPlayerCell.self, forCellReuseIdentifier: VideoPlayerCell.identifier)
    }
    
    private func configureCell(_ cell: VideoPlayerCell, at indexPath: IndexPath) {
        let videoURL = videos[indexPath.row].video
        let asset = AVURLAsset(url: videoURL)
        
        if resourceLoaderDelegates[videoURL] == nil {
            let delegate = ResourceLoaderDelegate(cache: cache, url: videoURL)
            resourceLoaderDelegates[videoURL] = delegate
            asset.resourceLoader.setDelegate(delegate, queue: .global(qos: .userInitiated))
        }
        
        let playerItem = AVPlayerItem(asset: asset)
        
        if currentItem != playerItem {
            player.replaceCurrentItem(with: playerItem)
            currentItem = playerItem
        }
        
        player.seek(to: .zero)
        
        cell.configure(player: player)
        cell.play()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { videos.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: VideoPlayerCell.identifier) as? VideoPlayerCell {
            cell.configure(with: videos[indexPath.row].thumbnail)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { tableView.bounds.height }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let videoCell = cell as? VideoPlayerCell else { return }
        videoCell.pause()
//        if let player = playerDictionary[indexPath] {
//            cache.storePlaybackTime(time: player.currentTime(), for: videos[indexPath.row].video)
//        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleIndexPaths = tableView.indexPathsForVisibleRows ?? []
        
        guard visibleIndexPaths.count == 1,
              let index = visibleIndexPaths.first,
              let cell = tableView.cellForRow(at: index) as? VideoPlayerCell else { return }
        
        configureCell(cell, at: index)
    }
}


// MARK: Dummy Data
extension ViewController {
    func extractData() {
        if let url = Bundle.main.url(forResource: "dummyData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decodedData = try JSONDecoder().decode(VideoDataResponse.self, from: data)
                converToViewModel(from: decodedData.videos ?? [])
            } catch let error {
                print("Error in decoding data: \(error)")
            }
        }
    }
    
    func converToViewModel(from data: [VideoDataResponse.VideoDataModel]) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            var convertedVideos: [VideoViewModel] = []
            
            data.forEach { datum in
                if let video = URL(string: datum.video ?? ""),
                   let image = URL(string: datum.thumbnail ?? "") {
                    convertedVideos.append(.init(video: video, thumbnail: image))
                }
            }
            
            DispatchQueue.main.async {
                self?.videos.append(contentsOf: convertedVideos)
                self?.tableView.reloadData()
            }
        }
    }
}
