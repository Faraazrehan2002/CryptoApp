//
//  ContentView.swift
//  CryptoApp
//
//  Created by Faraaz Rehan Junaidi Mohammed on 9/29/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = CryptoViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: CryptoViewModel())
                .environmentObject(vm)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            PortfolioView(viewModel: CryptoViewModel())
                .environmentObject(vm)
                .tabItem {
                    Image(systemName: "briefcase")
                    Text("Portfolio")
                }
            
            CryptoNewsView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("News")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .tint(.white) // Ensure consistent tab bar tint color
    }
}

#Preview {
    ContentView()
}

