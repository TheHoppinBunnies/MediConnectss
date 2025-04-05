//
//  ContentView.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI
import FirebaseCore

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.isLoggedIn {
            MainTabView()
                .onAppear {
                    appState.loadUserData()
                }
        } else {
            IntroView()
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $appState.currentTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppState.Tab.home)

            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(AppState.Tab.chat)

            AppointmentsView()
                .tabItem {
                    Label("Appointments", systemImage: "calendar")
                }
                .tag(AppState.Tab.appointments)

            MedicationsView()
                .tabItem {
                    Label("Medications", systemImage: "pill.fill")
                }
                .tag(AppState.Tab.medications)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(AppState.Tab.profile)

            MedicalPictureManagerView()
                .tabItem {
                    Label("Images", systemImage: "photo.on.rectangle.angled")
                }
                .tag(AppState.Tab.profile)
        }
    }
}
