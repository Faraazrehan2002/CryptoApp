//
//  SplashScreenView.swift
//  CryptoApp
//
//  Created by Faraaz Rehan Junaidi Mohammed on 12/5/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var animationScale = 1.0

    var body: some View {
        if isActive {
            ContentView() // Navigate to your main ContentView after the splash screen
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#851439"), Color(hex: "#151E52")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    Image(systemName: "bitcoinsign.circle.fill") // Use a cryptocurrency-related icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.yellow)
                        .scaleEffect(animationScale)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                animationScale = 1.2
                            }
                        }

                    Text("CryptoApp")
                        .font(.custom("Poppins-Bold", size: 32))
                        .foregroundColor(.white)
                        .padding(.top, 16)

                    Text("Your Gateway to the Cryptocurrency World")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 8)
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
}



#Preview {
    SplashScreenView()
}
