//
//  Model.swift
//  VideoPlayer
//
//  Created by Devansh Mohata on 15/08/24.
//

import Foundation

struct VideoDataResponse: Decodable {
    let videos: [VideoDataModel]?
    
    struct VideoDataModel: Decodable {
        let video: String?
        let thumbnail: String?
        
        enum CodingKeys: String, CodingKey {
            case video = "url"
            case thumbnail = "thumbnail"
        }
    }
}

struct VideoViewModel {
    let video: URL
    let thumbnail: URL
}
