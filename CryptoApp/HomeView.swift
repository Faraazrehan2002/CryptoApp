//
//  HomeView.swift
//  CryptoApp
//
//  Created by Faraaz Rehan Junaidi Mohammed on 10/1/24.
//

import SwiftUI
import Charts

struct HomeView: View {
    
    @ObservedObject var viewModel = CryptoViewModel()
    
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
            
            VStack(spacing: 20) {
                Text("Live Prices")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Check if marketCap is being updated
                HStack(spacing: 40) {
                    StatView(title: "Market Cap", value: viewModel.marketCap, change: nil)
                    StatView(title: "24hr Volume", value: viewModel.volume, change: nil)
                    StatView(title: "Coin Dominance", value: viewModel.dominance, change: nil)
                }
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                    TextField("Search by name or symbol", text: .constant(""))
                        .padding()
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 20) {
                    ScrollView{
                       
                        HStack {
                            Text("Coin")
                            Spacer()
                            Text("Price")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        
                        ForEach(viewModel.coins) { coin in
                            CoinRowView(coin: coin)
                        }
                        
                    }
                    
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 50)
        }
        .tabItem {
            Image(systemName: "house")
            Text("Home")
        }
    }
}


struct CoinRowView: View {
    var coin: Coin
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Text("\(coin.rank).")
                    .foregroundColor(.white)
                
                // Use AsyncImage to load the image from the URL
                AsyncImage(url: URL(string: coin.imageName)) { image in
                    image
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle()) // Optional: Clip the image to a circle
                } placeholder: {
                    // Placeholder while the image is loading
                    ProgressView()
                        .frame(width: 30, height: 30)
                }
                
                Text(coin.symbol)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(coin.price)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                Text(coin.change)
                    .foregroundColor(coin.change.contains("-") ? .red : .green)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 8)
    }
}



struct StatView: View {
    var title: String
    var value: String
    var change: String?

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .foregroundColor(.white)
                .font(.subheadline)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Optionally show percentage change (e.g., -15.2%)
            if let change = change {
                Text(change)
                    .foregroundColor(change.contains("-") ? .red : .green) // Red if negative, green if positive
                    .font(.subheadline)
            }
        }
    }
}

struct StatView_Previews: PreviewProvider {
    static var previews: some View {
        StatView(title: "Market Cap", value: "$1.24Tr", change: "-15.2%")
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}


#Preview {
    HomeView()
}
