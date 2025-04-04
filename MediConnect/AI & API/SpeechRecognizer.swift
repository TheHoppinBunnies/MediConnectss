//
//  SpeechRecognizer.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-22.
//

import SwiftUI
import AVKit
import AVFoundation
import Speech

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onFinish: () -> Void
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}

@Observable
class SpeechRecognizer {

    var recognizedText: String = "No speech recognized"
    var startedListening: Bool = false
    var audioEngine: AVAudioEngine!
    var speechRecognizer: SFSpeechRecognizer!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    var recognitionTask: SFSpeechRecognitionTask!

    init() {
        setupSpeechRecognition()
    }

    func setupSpeechRecognition() {
        audioEngine = AVAudioEngine()
        speechRecognizer = SFSpeechRecognizer()

        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition not authorized")
                @unknown default:
                    fatalError("Unknown authorization status")
                }
            }
        }
    }

    func startListening() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        startedListening = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            self.recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try! audioEngine.start()

        speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                Task {
                    self.recognizedText = result.bestTranscription.formattedString
                }
            }

            if error != nil || result?.isFinal == true {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        startedListening = false
    }
}

