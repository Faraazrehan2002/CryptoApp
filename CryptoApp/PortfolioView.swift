//
//  PortfolioView.swift
//  CryptoApp
//
//  Created by Faraaz Rehan Junaidi Mohammed on 10/1/24.
//

import SwiftUI



struct PortfolioView: View {
    
    @ObservedObject var viewModel = CryptoViewModel()
    
    @State private var searchText = ""
    var filteredCoins: [CoinGeckoCoin] {
            if searchText.isEmpty {
                return viewModel.coins // Return all coins if search text is empty
            } else {
                return viewModel.coins.filter { coin in
                    coin.name.localizedCaseInsensitiveContains(searchText) ||
                    coin.symbol.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    
    
    var body: some View {
        NavigationView{
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
                    HStack{
                        NavigationLink(destination: EditPortfolioView()) {
                            Text("Edit")
                                .foregroundColor(.white)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .padding()
                        Spacer()
                    }
                    Text("Portfolio")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Check if user dominance,24hr volume,and Value are being updated
                    HStack(alignment: .top,spacing: 36){
                    
                        VStack {
                                Text("Top Coin Dominance")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .alignmentGuide(.top) { d in d[.top] } // Align to the top
                                Text("Number here")
                                    .alignmentGuide(.top) { d in d[.top] } // Ensure even alignment
                            }
                            
                            VStack {
                                Text("24hr Volume")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .alignmentGuide(.top) { d in d[.top] } // Align to the top
                                // Optional: You can add a placeholder for consistency if needed
                                Text("") // Add an empty text view if needed for spacing
                                    .alignmentGuide(.top) { d in d[.top] }
                            }
                            
                            VStack {
                                Text("Portfolio Value")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .alignmentGuide(.top) { d in d[.top] } // Align to the top
                                // Optional: Add a second line if needed for consistency
                                Text("")
                                    .alignmentGuide(.top) { d in d[.top] }
                            }
                    }
                    // StatView(title: "Market Cap", value: viewModel.marketCap, change: nil)
                    // StatView(title: "24hr Volume", value: viewModel.volume, change: nil)
                    // StatView(title: "Coin Dominance", value: viewModel.dominance, change: nil)
                    .foregroundColor(.white)
                    .padding()
                    
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                        
                        ZStack(alignment: .leading) {
                            if searchText.isEmpty {
                                Text("Search")
                                    .foregroundColor(.gray)
                            }
                            TextField("", text: $searchText)
                                .autocapitalization(.none) // Disable auto-capitalization
                                .disableAutocorrection(true) // Disable autocorrection
                                
                        }
                    }
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(color: .white.opacity(0.15), radius: 10, x: 0, y: 0))
                    .padding(.horizontal, 6)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        ScrollView{
                            
                            HStack {
                                Text("Coin")
                                Spacer()
                                Text("Holdings")
                                Spacer()
                                Text("Price")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            
                            //ForEach(viewModel.coins) { coin in
                            //  CoinRowView(coin: coin)
                            //}
                            
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.top)
                    
                    Spacer()
                }
                //.padding(.top, 50)
            }
            
        }
        .tabItem{
            Image(systemName: "briefcase")
            Text("Portfolio")
        }
        
    }// view ends
    
}
    



#Preview {
    PortfolioView()
}
