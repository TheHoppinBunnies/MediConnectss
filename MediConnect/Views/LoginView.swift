////
////  LoginView.swift
////  MediConnect
////
////  Created by Othmane EL MARIKY on 2025-03-21.
////
//
//import SwiftUI
//
//struct LoginView: View {
//    @EnvironmentObject var appState: AppState
//    @State private var email = ""
//    @State private var password = ""
//    @State private var isLoading = false
//
//    var body: some View {
//        VStack(spacing: 30) {
//            // Logo and Title
//            VStack {
//                Image(systemName: "heart.text.square.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 100, height: 100)
//                    .foregroundColor(.blue)
//
//                Text("MediConnect")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//
//                Text("AI-Powered Telemedicine")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//
//            // Login Form
//            VStack(spacing: 15) {
//                TextField("Email", text: $email)
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(10)
//                    .keyboardType(.emailAddress)
//                    .autocapitalization(.none)
//
//                SecureField("Password", text: $password)
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(10)
//
//                Button(action: {
//                    isLoading = true
//                    appState.login(email: email, password: password)
//                }) {
//                    if isLoading {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.blue)
//                            .cornerRadius(10)
//                    } else {
//                        Text("Sign In")
//                            .fontWeight(.semibold)
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.blue)
//                            .cornerRadius(10)
//                    }
//                }
//                .disabled(email.isEmpty || password.isEmpty || isLoading)
//
//                Button("Create an account") {
//                    // Navigate to sign up
//                }
//                .foregroundColor(.blue)
//
//                Button("Forgot password?") {
//                    // Navigate to password reset
//                }
//                .foregroundColor(.blue)
//            }
//            .padding(.horizontal)
//        }
//        .padding()
//    }
//}
