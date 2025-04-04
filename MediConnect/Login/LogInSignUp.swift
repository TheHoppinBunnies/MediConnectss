//
//  ContentView.swift
//  LoginKit
//
//  Created by Othmane EL MARIKY on 2023-08-13.
//

import SwiftUI

struct LogInSignUp: View {
    
    @State private var showSignup: Bool = false
    
    var body: some View {
        NavigationStack {
            Login(showSignup: $showSignup)
                .navigationDestination(isPresented: $showSignup) {
                    SignUp(showSignup: $showSignup)
                }
        }
        .overlay {
            if #available(iOS 17, *) {
                CircleView()
                    .animation(.bouncy(duration: 0.45, extraBounce: 0), value: showSignup)
            } else {
                CircleView()
                    .animation(.easeInOut(duration: 0.3), value: showSignup)
            }
        }
    }
    @ViewBuilder
    func CircleView() -> some View {
        Circle()
            .fill(.linearGradient(colors: [.appYellow, .appYellow, .gray], startPoint: .top, endPoint: .bottom))
            .frame(width: 200, height: 200)
        
            .offset(x: showSignup ? 90 : -90, y: -90)
            .blur(radius: 15)
            .hSpacing(showSignup ? .trailing : .leading)
            .vSpacing(.top)
    }
}
