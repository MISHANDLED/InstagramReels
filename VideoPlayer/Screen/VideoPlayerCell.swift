//
//  VideoPlayerCell.swift
//  VideoPlayer
//
//  Created by Devansh Mohata on 14/08/24.
//

import AVKit
import SDWebImage
import SnapKit
import UIKit

class VideoPlayerCell: UITableViewCell {
    // MARK: UI Elements
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    private var titleImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private var playIcon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "play.fill")
        return image
    }()
    
    private lazy var videoPlayerView: VideoPlayerView = {
        let view = VideoPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not to be init by nib")
    }
    
    
    // MARK: prepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        videoPlayerView.resetPlayer()
    }
    
    // MARK: setupViews
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleImage)
        containerView.addSubview(playIcon)
        containerView.addSubview(videoPlayerView)
    }
    
    
    // MARK: setupLayouts
    private func setupLayouts() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleImage.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        }
        
        playIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(120)
            make.width.equalTo(playIcon.snp.height)
        }
        
        videoPlayerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayouts()
    }
    
    // MARK: configure
    func configure(player: AVPlayer) {
        videoPlayerView.configure(with: player)
        toggleVideoPlayer(isShow: true)
    }
    
    func configure(with image: URL) {
        titleImage.sd_setImage(with: image)
        toggleVideoPlayer(isShow: false)
    }
    
    func pause() {
        videoPlayerView.pause()
    }
    
    func play() {
        videoPlayerView.play()
    }
    
    private func toggleVideoPlayer(isShow: Bool) {
        videoPlayerView.isHidden = !isShow
        titleImage.isHidden = isShow
        playIcon.isHidden = isShow
    }
}
