//
//  VideoCallView.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI

struct VideoCallView: View {
    let isAI: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var isMuted = false
    @State private var isCameraOff = false
    @State private var elapsedTime = 0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            // Video background - in a real app this would be the video feed
            Color.black
                .edgesIgnoringSafeArea(.all)

            // Remote video placeholder
            VStack {
                if isAI {
                    Image(systemName: "brain")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                    Text("AI Consultation")
                        .font(.title)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                    Text("Dr. Sarah Johnson")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }

            // Self view (picture-in-picture)
            VStack {
                HStack {
                    Spacer()

                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                            .frame(width: 100, height: 150)

                        if isCameraOff {
                            Image(systemName: "video.slash.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "person.crop.rectangle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }

                Spacer()
            }

            // Call controls
            VStack {
                Spacer()

                // Timer
                Text(timeString(from: elapsedTime))
                    .font(.system(.title3, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.bottom)

                // Control buttons
                HStack(spacing: 30) {
                    Button(action: {
                        isMuted.toggle()
                    }) {
                        Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 25))
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }

                    Button(action: {
                        // End call
                        timer?.invalidate()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 25))
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }

                    Button(action: {
                        isCameraOff.toggle()
                    }) {
                        Image(systemName: isCameraOff ? "video.slash.fill" : "video.fill")
                            .font(.system(size: 25))
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }

    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
