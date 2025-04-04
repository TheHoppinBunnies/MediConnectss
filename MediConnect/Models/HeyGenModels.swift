//
//  HeyGen.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-30.
//

import Foundation

struct HeyGenVideoRequest: Codable {
    let video_inputs: [VideoInput]
    let dimension: Dimension

    struct VideoInput: Codable {
        let character: Character
        let voice: Voice

        struct Character: Codable {
            let type: String
            let avatar_id: String
            let avatar_style: String
        }

        struct Voice: Codable {
            let type: String
            let input_text: String
            let voice_id: String
            let speed: Double
        }
    }

    struct Dimension: Codable {
        let width: Int
        let height: Int
    }
}

struct HeyGenVideoResponse: Decodable {
    let error: String?
    let data: VideoData

    struct VideoData: Decodable {
        let video_id: String
    }
}

struct HeyGenVideoStatusResponse: Decodable {
    let code: Int
    let data: VideoStatusData
    let message: String

    struct VideoStatusData: Decodable {
        let callback_id: String?
        let caption_url: String?
        let duration: Double?
        let error: String?
        let gif_url: String?
        let id: String
        let status: String
        let thumbnail_url: String?
        let video_url: String?
        let video_url_caption: String?
    }
}
