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
            HomeView()
                .environmentObject(vm) 
            PortfolioView()
            SettingsView()
        }
        .tint(.white)
    }
}

#Preview {
    ContentView()
}
