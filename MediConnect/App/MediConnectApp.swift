//
//  MediConnectApp.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI
import FirebaseCore

@main
struct TelemedicineApp: App {
    @StateObject private var appState = AppState()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
//            AvatarSynthesisView()
//            PomodoroTimerView()
            ContentView()
                .environmentObject(appState)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
