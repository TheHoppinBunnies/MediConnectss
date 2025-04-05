//
//  Exercices.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-04-04.
//

import SwiftUI
import UserNotifications

struct Exercise: Identifiable {
    let id: UUID = UUID()
    var title: String
    var instructions: [String]
    var music: String
    var time: Double
    var category: String
}

struct ExerciceView: View {
    let exercise: Exercise

    var body: some View {
        Text(exercise.title)
    }
}

struct PomodoroTimerView: View {
    @State private var timeRemaining: Int = 25 * 60 // Default to 25 minutes
    @State private var isRunning: Bool = false
    @State private var isWorkSession: Bool = true // Track whether it's a work or break session
    @State private var timer: Timer? = nil

    private var workTime: Int = 25 * 60
    private var breakTime: Int = 5 * 60

    private var totalTime: Int {
        return isWorkSession ? workTime : breakTime
    }

    private var progress: Double {
        return 1.0 - Double(timeRemaining) / Double(totalTime)
    }

    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(isWorkSession ? "Work Session" : "Break Session")
                .font(.largeTitle)
                .fontWeight(.bold)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(isWorkSession ? Color.blue : Color.green, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress)

                Text(formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
            }
            .frame(width: 200, height: 200)

            HStack(spacing: 20) {
                Button(action: startTimer) {
                    Text(isRunning ? "Pause" : "Start")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isRunning ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: resetTimer) {
                    Text("Reset")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onAppear(perform: requestNotificationPermissions)
        .onDisappear { stopTimer() }
    }

    private func startTimer() {
        if isRunning {
            stopTimer()
        } else {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    sendNotification()
                    switchSession()
                }
            }
        }
    }

    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        stopTimer()
        timeRemaining = totalTime
    }

    private func switchSession() {
        stopTimer()
        isWorkSession.toggle()
        timeRemaining = totalTime
        startTimer() // Automatically start the next session
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = isWorkSession ? "Work Session Complete" : "Break Session Complete"
        content.body = isWorkSession ? "Time to take a break!" : "Time to get back to work!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }
}

struct PomodoroTimerView_Previews: PreviewProvider {
    static var previews: some View {
        PomodoroTimerView()
    }
}
