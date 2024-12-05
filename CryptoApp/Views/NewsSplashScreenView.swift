//
//  NewsSplashScreenView.swift
//  CryptoApp
//
//  Created by Faraaz Rehan Junaidi Mohammed on 12/5/24.
//

import SwiftUI

struct NewsSplashScreenView: View {
    @State private var isActive = false
    @State private var fadeOpacity = 0.0

    var body: some View {
        ZStack {
            if isActive {
                CryptoNewsView() // Navigate directly to CryptoNewsView
            } else {
                ZStack {
                    // Background Gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#0A0F30"), Color(hex: "#1A243D")]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    // Splash Screen Content
                    VStack(spacing: 20) {
                        // News Icon
                        Image(systemName: "newspaper.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .opacity(fadeOpacity)
                            .onAppear {
                                withAnimation(.easeIn(duration: 1.5)) {
                                    fadeOpacity = 1.0
                                }
                            }

                        // Title
                        Text("Crypto News")
                            .font(.custom("Poppins-Bold", size: 32))
                            .foregroundColor(.white)

                        // Subtitle
                        Text("Stay updated with the latest in cryptocurrency")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Splash screen duration
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}

