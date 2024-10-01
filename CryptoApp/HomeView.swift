//
//  HomeView.swift
//  CryptoApp
//
//  Created by Faraaz Rehan Junaidi Mohammed on 10/1/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#851439"), // Magenta-like color
                    Color(hex: "#151E52")  // Dark blue color
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea() // Ensures it covers the entire screen
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
        }.tabItem{
            Image(systemName: "house")
            Text("Home")
        }
        
    }// view ends
}

#Preview {
    HomeView()
}
