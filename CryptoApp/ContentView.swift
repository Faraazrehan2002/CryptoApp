//
//  ContentView.swift
//  CryptoApp
//
//  Created by Faraaz Rehan Junaidi Mohammed on 9/29/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            HomeView()
            PortfolioView()
            SettingsView()
    }.tint(.white)        // Ensures unselected tab icons and text are also white
    }
}


#Preview {
    ContentView()
}
