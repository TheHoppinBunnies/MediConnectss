//
//  ChatView.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI
import AVKit
import Foundation
import AVFoundation
import Speech
import GoogleGenerativeAI
import FirebaseFirestore
import FirebaseAuth

var response: LocalizedStringKey = ""

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @State private var newMessage = ""
    @State private var showContactDoctorSheet = false

    private let apiKey: String = "AIzaSyDH_b_AMic_MTI3412RPMb7bCr0-2H3abM"

    @State private var speechRecognizer = SpeechRecognizer()
    @State private var audioData: Data? = nil
    @State private var audioPlayerDelegate: AudioPlayerDelegate? = nil
    @State private var audioPlayer: AVAudioPlayer? = nil

    @State private var player = AVPlayer()
    @State private var isSpeechEnabled = false
    @State private var isTalking = false
    @State private var urlString = ""
    @State private var taps = 0
    @State private var aiResponse = ""
    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)

    @ObservedObject var viewModel = AIMessagesViewModel()

    @State var chatType: String = "AI"
    let chatTypes = ["AI", "Doctor"]

    var animation: Animation {
        return .linear(duration: 0.5).repeatForever()
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Chat with")
                        .font(.largeTitle)
                        .bold()
                        .hSpacing(.leading)

                    Picker("\(chatType)", selection: $chatType) {
                        ForEach(chatTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .font(.largeTitle)
                    .bold()
                    .hSpacing(.leading).padding(.leading, -40)

                }

                // Chat messages
                ScrollViewReader { scrollView in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(appState.chatHistory) { message in
                                ChatBubble(message: message)
                            }
                            .onChange(of: appState.chatHistory.count) {
                                if let lastMessage = appState.chatHistory.last {
                                    scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                        .padding()
                    }
                }

                HStack {
                    TextField("Type a message", text: $newMessage)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)

                    Button {
                        withAnimation() {
                            isTalking.toggle()
                            if speechRecognizer.audioEngine.isRunning {
                                speechRecognizer.stopListening()
                            } else {
                                speechRecognizer.startListening()
                            }
                        }
                    } label: {
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(isTalking ? .red : .gray)
                    }
                    .onAppear {
                        speechRecognizer.setupSpeechRecognition()
                    }
                    .onChange(of: speechRecognizer.recognizedText) { oldValue, newValue in
                        newMessage = newValue
                    }

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                    .disabled(newMessage.isEmpty)
                }
                .padding()
            }
            //            .navigationTitle("Chat with AI")
            .navigationBarItems(trailing:
                                    Button(action: {
                showContactDoctorSheet = true
            }) {
                Image(systemName: "video.fill")
                    .foregroundColor(.blue)
            }
            )
            .sheet(isPresented: $showContactDoctorSheet) {
                ContactDoctorView()
            }
        }
    }

    func sendMessage() {
        self.taps += 1
        guard !newMessage.isEmpty else { return }

        let userMessage = ChatMessage(
            id: UUID(),
            sender: "user",
            content: newMessage,
            timestamp: Date()
        )

        appState.chatHistory.append(userMessage)

        let db = Firestore.firestore()
        let cardRef = db.collection("messages").document()
        let cardData: [String: Any] = [
            "id": UUID(),
            "sender": "user",
            "content": newMessage,
            "timestamp": Date(),
            "uid": String(Auth.auth().currentUser!.uid)
        ]

        cardRef.setData(cardData) { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }

        let messageSent = newMessage
        newMessage = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Task {
                if let aiResponse = await generateResponse(text: messageSent) {
                    appState.chatHistory.append(aiResponse)
                }
            }
        }
    }

    func generateResponse(text: String) async -> ChatMessage? {
        do {
            let result = try await model.generateContent(text)
            self.aiResponse = result.text!
            print(self.aiResponse)

            let db = Firestore.firestore()
            let cardRef = db.collection("expenses").document()
            let cardData: [String: Any] = [
                "id": UUID(),
                "sender": "AI",
                "content": self.aiResponse,
                "timestamp": Date(),
                "uid": String(Auth.auth().currentUser!.uid)
            ]

            do {
              try await db.collection("messages").document().setData(cardData)
              print("Document successfully written!")
            } catch {
              print("Error writing document: \(error)")
            }

            return ChatMessage(
                id: UUID(),
                sender: "AI",
                content: result.text!,
                timestamp: Date()
            )
        } catch {
            response = "Something went wrong! \n\(error.localizedDescription)"
            return nil
        }
    }

    private func fetchAndPlayTTS(text: String) {

        fetchGoogleTTSDataWithAPIKey(text: text, apiKey: apiKey) { fetchedData in
            DispatchQueue.main.async {
                guard let fetchedData = fetchedData else {
                    print("No audio data returned from TTS.")
                    return
                }

                self.audioData = fetchedData
                do {
                    let player = try AVAudioPlayer(data: fetchedData)

                    let delegate = AudioPlayerDelegate {

                        print("Playback finished. Stopping & cleaning up the player.")
                        player.stop()
                        audioPlayer = nil
                        audioPlayerDelegate = nil
                    }

                    player.delegate = delegate

                    self.audioPlayer = player
                    self.audioPlayerDelegate = delegate

                    player.prepareToPlay()
                    player.play()
                } catch {
                    print("Error creating AVAudioPlayer: \(error)")
                }
            }
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(AppState())
}
