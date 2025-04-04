//
//  TTS.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-22.
//

import SwiftUI
import AVFoundation

struct GoogleTTSResponse: Decodable {
    let audioContent: String
}

func fetchGoogleTTSDataWithAPIKey(text: String, apiKey: String, completion: @escaping (Data?) -> Void) {
    guard let url = URL(string: "https://texttospeech.googleapis.com/v1/text:synthesize?key=\(apiKey)") else {
        completion(nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let requestBody: [String: Any] = [
        "input": [
            "text": text
        ],
        "voice": [
            "languageCode": "en-US",
            "name": "en-US-Standard-H"
        ],
        "audioConfig": [
            "audioEncoding": "MP3"
        ]
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch {
        print("Failed to encode JSON request: \(error)")
        completion(nil)
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("TTS request error: \(error.localizedDescription)")
            completion(nil)
            return
        }

        guard let data = data else {
            print("No data in TTS response.")
            completion(nil)
            return
        }

        if let httpResponse = response as? HTTPURLResponse {
            print("TTS response code: \(httpResponse.statusCode)")
        }

        do {
            let ttsResponse = try JSONDecoder().decode(GoogleTTSResponse.self, from: data)
            if let rawData = Data(base64Encoded: ttsResponse.audioContent) {
                completion(rawData)
            } else {
                print("Failed to decode base64 audio.")
                completion(nil)
            }
        } catch {
            print("Error decoding TTS response JSON: \(error)")
            completion(nil)
        }
    }
    task.resume()
}
