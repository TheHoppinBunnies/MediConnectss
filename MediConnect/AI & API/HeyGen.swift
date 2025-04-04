//
//  HeyGen.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-30.
//

import SwiftUI
import AVKit

class HeyGenAPIService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.heygen.com"

    @Published var videoStatus: String = "Not Started"
    @Published var videoURL: URL?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func generateVideo(text: String, avatarID: String = "Angela-inTshirt-20220820", voiceID: String = "1bd001e7e50f421d891986aad5158bc8") {
        self.isLoading = true
        self.videoStatus = "Generating"
        self.errorMessage = nil
        self.videoURL = nil

        let request = HeyGenVideoRequest(
            video_inputs: [
                HeyGenVideoRequest.VideoInput(
                    character: HeyGenVideoRequest.VideoInput.Character(
                        type: "avatar",
                        avatar_id: avatarID,
                        avatar_style: "normal"
                    ),
                    voice: HeyGenVideoRequest.VideoInput.Voice(
                        type: "text",
                        input_text: text,
                        voice_id: voiceID,
                        speed: 1.1
                    )
                )
            ],
            dimension: HeyGenVideoRequest.Dimension(
                width: 1280,
                height: 720
            )
        )

        guard let url = URL(string: "\(baseURL)/v2/video/generate") else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            self.errorMessage = "Failed to encode request: \(error.localizedDescription)"
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Request failed: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                    return
                }

                do {
                    let response = try JSONDecoder().decode(HeyGenVideoResponse.self, from: data)

                    if let error = response.error, !error.isEmpty {
                        self.errorMessage = "API Error: \(error)"
                        self.isLoading = false
                    } else {
                        self.checkVideoStatus(videoID: response.data.video_id)
                    }
                } catch {
                    self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }

    func checkVideoStatus(videoID: String) {
        guard let url = URL(string: "\(baseURL)/v1/video_status.get?video_id=\(videoID)") else {
            self.errorMessage = "Invalid URL for status check"
            self.isLoading = false
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Status check failed: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received for status check"
                    self.isLoading = false
                    return
                }

                do {
                    let response = try JSONDecoder().decode(HeyGenVideoStatusResponse.self, from: data)

                    if let error = response.data.error, !error.isEmpty {
                        self.errorMessage = "API Error: \(error)"
                        self.isLoading = false
                        return
                    }

                    let status = response.data.status
                    self.videoStatus = status

                    switch status {
                    case "completed":
                        if let videoURLString = response.data.video_url, let url = URL(string: videoURLString) {
                            self.videoURL = url
                            self.isLoading = false
                        } else {
                            self.errorMessage = "Video URL is missing or invalid"
                            self.isLoading = false
                        }

                    case "pending", "processing", "waiting":
                        // Continue polling after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.checkVideoStatus(videoID: videoID)
                        }

                    default:
                        self.errorMessage = "Unknown status: \(status)"
                        self.isLoading = false
                    }
                } catch {
                    self.errorMessage = "Failed to decode status response: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

// MARK: - Main View
struct HeyGenVideoView: View {
    @StateObject private var apiService = HeyGenAPIService(apiKey: "ZjRkMWFhZTgxZjdjNDIzMWIwYjJhMmNmOTJmYzZkYmUtMTc0MTAxOTAzNA==")
    @State private var inputText: String = "Hey there! I am Jonathan, your very own virtual doctor. Tell me, what seems to be bothering you today?"

    var body: some View {
        NavigationView {
            VStack {
                // Input Section
                VStack(alignment: .leading) {
                    Text("Enter text for the virtual avatar to speak:")
                        .font(.headline)
                        .padding(.bottom, 4)

                    TextEditor(text: $inputText)
                        .frame(height: 100)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding()

                // Generate Button
                Button(action: {
                    apiService.generateVideo(text: inputText)
                }) {
                    if apiService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.horizontal)
                    } else {
                        Text("Generate Video")
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }
                }
                .frame(height: 44)
                .background(apiService.isLoading ? Color.gray : Color.blue)
                .cornerRadius(8)
                .disabled(apiService.isLoading || inputText.isEmpty)
                .padding()

                // Status Display
                if apiService.isLoading {
                    VStack {
                        Text("Status: \(apiService.videoStatus)")
                            .fontWeight(.medium)

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.top, 4)
                    }
                    .padding()
                }

                // Video Player
                if let videoURL = apiService.videoURL {
                    Divider()

                    Text("Video Ready!")
                        .font(.headline)
                        .padding(.top)

                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(height: 300)
                        .cornerRadius(12)
                        .padding()
                }

                // Error Message
                if let errorMessage = apiService.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .navigationTitle("HeyGen Avatar")
        }
    }
}
