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
    
    private var lastVisibleIndex: Int = 0
    private var cache: VideoCache = .init()
    private var resourceLoaderDelegates: [URL: ResourceLoaderDelegate] = [:]
    private var videos: [VideoViewModel] = []
    
    
    private let playerManager = PlayerManager()
    
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
        preparePlayersForIndex(indexPath.row)
        
        let player = playerManager.currentPlayer()
        cell.configure(player: player)
        cell.play()
    }
    
    private func preparePlayersForIndex(_ index: Int) {
        guard index >= 0 && index < videos.count else { return }
        
        let prevIndex = max(0, index - 1)
        let nextIndex = min(videos.count - 1, index + 1)
        
        playerManager.preparePlayer(at: -1, with: videos[prevIndex].video, cache: cache, resourceLoaderDelegates: &resourceLoaderDelegates)
        playerManager.preparePlayer(at: 0, with: videos[index].video, cache: cache, resourceLoaderDelegates: &resourceLoaderDelegates)
        playerManager.preparePlayer(at: 1, with: videos[nextIndex].video, cache: cache, resourceLoaderDelegates: &resourceLoaderDelegates)
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
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = tableView.indexPathsForVisibleRows?.first,
              let cell = tableView.cellForRow(at: indexPath) as? VideoPlayerCell else { return }
        
        let currentIndex = indexPath.row
        
        if currentIndex > lastVisibleIndex {
            // Scrolled down
            playerManager.advanceToNext()
        } else if currentIndex < lastVisibleIndex {
            // Scrolled up
            playerManager.retreatToPrevious()
        }
        
        lastVisibleIndex = currentIndex
        configureCell(cell, at: indexPath)
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
