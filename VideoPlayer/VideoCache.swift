//
//  VideoCache.swift
//  VideoPlayer
//
//  Created by Devansh Mohata on 15/08/24.
//

import CoreMedia
import Foundation

class VideoCache {
    private var cache: [URL: [Int64: Data]] = [:]
    private var playbackTimes: [URL: CMTime] = [:]
    
    func getData(for url: URL, requestedRange offset: Int64, length: Int64) -> (Data, Range<Int64>)? {
        guard let videoCache = cache[url] else { return nil }
        
        let availableRanges = videoCache.keys.sorted()
        guard let startIndex = availableRanges.firstIndex(where: { $0 <= offset }),
              let endIndex = availableRanges.lastIndex(where: { $0 + Int64(videoCache[$0]?.count ?? 0) >= offset + length }) else {
            return nil
        }
        
        let relevantRanges = availableRanges[startIndex...endIndex]
        var combinedData = Data()
        var coveredRange: Range<Int64>?
        
        for rangeStart in relevantRanges {
            guard let rangeData = videoCache[rangeStart] else { continue }
            let rangeEnd = rangeStart + Int64(rangeData.count)
            
            if rangeStart <= offset && rangeEnd >= offset + length {
                let startDelta = Int(offset - rangeStart)
                let endDelta = Int(offset + length - rangeStart)
                return (rangeData[startDelta..<endDelta], offset..<(offset + length))
            }
            
            if let currentRange = coveredRange {
                if rangeStart <= currentRange.upperBound {
                    coveredRange = currentRange.lowerBound..<max(currentRange.upperBound, rangeEnd)
                } else {
                    break
                }
            } else {
                coveredRange = rangeStart..<rangeEnd
            }
            
            combinedData.append(rangeData)
        }
        
        guard let finalRange = coveredRange else { return nil }
        let startDelta = Int(max(offset - finalRange.lowerBound, 0))
        let endDelta = Int(min(offset + length - finalRange.lowerBound, Int64(combinedData.count)))
        
        return (combinedData[startDelta..<endDelta], max(offset, finalRange.lowerBound)..<min(offset + length, finalRange.upperBound))
    }
    
    func store(data: Data, for url: URL, offset: Int64) {
        if cache[url] == nil {
            cache[url] = [:]
        }
        cache[url]?[offset] = data
    }
    
    func storePlaybackTime(time: CMTime, for url: URL) {
        playbackTimes[url] = time
    }
    
    func getPlaybackTime(for url: URL) -> CMTime? {
        return playbackTimes[url]
    }
}
