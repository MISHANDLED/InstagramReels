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
    
    private let playerLayer = AVPlayerLayer()
    var player: AVPlayer?
    
    
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
        
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
    
    // MARK: setupViews
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleImage)
        containerView.addSubview(playIcon)
        
        containerView.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resizeAspectFill
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
        }
        
        playerLayer.frame = containerView.bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayouts()
    }
    
    // MARK: configure
    func configure(player: AVPlayer) {
        self.player?.currentItem?.asset.cancelLoading()
        self.player?.replaceCurrentItem(with: nil)
        
        self.player = player
        playerLayer.player = player
    }
    
    func pause() {
        player?.pause()
    }
    
    func play() {
        player?.play()
    }
}
