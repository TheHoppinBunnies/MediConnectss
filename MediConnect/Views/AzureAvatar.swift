//
//  AzureAvatar.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-30.
//

import SwiftUI
import AVKit

struct AvatarSynthesisView: View {
    @StateObject private var service = AvatarSynthesisService()
    @State private var inputText = "Hi, I'm a virtual assistant created by Microsoft."
    @State private var selectedVoice = "en-US-AndrewMultilingualNeural"
    @State private var selectedCharacter = "Lisa"
    @State private var selectedStyle = "casual-sitting"
    @State private var player: AVPlayer?

    let availableVoices = ["en-US-AndrewMultilingualNeural", "en-US-JennyMultilingualNeural"]
    let availableCharacters = ["Lisa", "Jeff", "Sarah", "Ryan"]
    let availableStyles = ["casual-sitting", "formal-standing", "professional-desk"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Azure Avatar Synthesis")
                    .font(.largeTitle)
                    .padding(.bottom)

                // Input text field
                VStack(alignment: .leading) {
                    Text("Message:")
                        .font(.headline)
                    TextEditor(text: $inputText)
                        .frame(height: 100)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }

                // Options
                HStack {
                    VStack(alignment: .leading) {
                        Text("Voice:")
                            .font(.headline)
                        Picker("Voice", selection: $selectedVoice) {
                            ForEach(availableVoices, id: \.self) { voice in
                                Text(voice).tag(voice)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }

                    Spacer()

                    VStack(alignment: .leading) {
                        Text("Character:")
                            .font(.headline)
                        Picker("Character", selection: $selectedCharacter) {
                            ForEach(availableCharacters, id: \.self) { character in
                                Text(character).tag(character)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }

                VStack(alignment: .leading) {
                    Text("Style:")
                        .font(.headline)
                    Picker("Style", selection: $selectedStyle) {
                        ForEach(availableStyles, id: \.self) { style in
                            Text(style).tag(style)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                // Submit button
                Button(action: {
                    service.submitJob(
                        text: inputText,
                        voice: selectedVoice,
                        character: selectedCharacter,
                        style: selectedStyle
                    )
                }) {
                    Text("Generate Avatar Video")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(service.isLoading)

                // Status information
                VStack(alignment: .leading, spacing: 8) {
                    Text(service.statusMessage)
                        .font(.headline)

                    if let jobId = service.jobId {
                        Text("Job ID: \(jobId)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    if let error = service.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(.vertical)

                // Video player
                if let downloadUrl = service.downloadUrl, let url = URL(string: downloadUrl) {
                    VStack(alignment: .leading) {
                        Text("Generated Video")
                            .font(.headline)

                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: 300)
                            .cornerRadius(10)
                            .onAppear {
                                self.player = AVPlayer(url: url)
                                self.player?.play()
                            }
                    }
                } else if service.isLoading || service.jobId != nil {
                    VStack {
                        if service.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        Text("Video will appear here when ready")
                            .foregroundColor(.gray)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}
