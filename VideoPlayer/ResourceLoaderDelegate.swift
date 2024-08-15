//
//  ResourceLoaderDelegate.swift
//  VideoPlayer
//
//  Created by Devansh Mohata on 15/08/24.
//

import AVKit
import Foundation

class ResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private let cache: VideoCache
    private let url: URL
    private var pendingRequests: [AVAssetResourceLoadingRequest] = []
    private var downloadTask: URLSessionDataTask?
    
    init(cache: VideoCache, url: URL) {
        self.cache = cache
        self.url = url
        
        super.init()
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        let length: Int64 = Int64(loadingRequest.dataRequest?.requestedLength ?? 0)
        
        if let (cachedData, cachedRange) = cache.getData(for: url, requestedRange: loadingRequest.dataRequest?.requestedOffset ?? 0, length: length) {
            loadingRequest.dataRequest?.respond(with: cachedData)
            
            if cachedRange.upperBound >= (loadingRequest.dataRequest?.currentOffset ?? 0) + length {
                loadingRequest.finishLoading()
            } else {
                pendingRequests.append(loadingRequest)
                startDownloadIfNeeded(from: cachedRange.upperBound)
            }
        } else {
            pendingRequests.append(loadingRequest)
            startDownloadIfNeeded(from: loadingRequest.dataRequest?.requestedOffset ?? 0)
        }
        
        return true
    }
    
    private func startDownloadIfNeeded(from offset: Int64) {
        guard downloadTask == nil else { return }
        
        var request = URLRequest(url: url)
        request.setValue("bytes=\(offset)-", forHTTPHeaderField: "Range")
        
        downloadTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, let data = data else {
                self?.pendingRequests.forEach { $0.finishLoading(with: error) }
                self?.pendingRequests.removeAll()
                return
            }
            
            self.cache.store(data: data, for: self.url, offset: offset)
            self.processPendingRequests()
            self.downloadTask = nil
        }
        
        downloadTask?.resume()
    }
    
    private func processPendingRequests() {
        pendingRequests = pendingRequests.filter { request in
            guard let dataRequest = request.dataRequest else { return false }
            
            if let (data, _) = cache.getData(for: url, requestedRange: dataRequest.requestedOffset, length: Int64(dataRequest.requestedLength)) {
                dataRequest.respond(with: data)
                request.finishLoading()
                return false
            }
            
            return true
        }
    }
}
