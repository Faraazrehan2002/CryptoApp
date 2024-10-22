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
            return viewModel.coins
        } else {
            return viewModel.coins.filter { coin in
                coin.name.localizedCaseInsensitiveContains(searchText) ||
                coin.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#851439"),
                        Color(hex: "#151E52")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack{
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
                    
                    VStack(spacing: 20) {
                        Text("Portfolio")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Stats View (Market Cap, 24hr Volume, Coin Dominance)
                        HStack(alignment: .top, spacing: 36) {
                            
                            Text("")
                            Text("")
                            Text("")

                            /*StatView(
                                title: "Market Cap",
                                value: viewModel.marketCap,
                                percentageChange: viewModel.marketCapPercentageChange
                            )
                            StatView(
                                title: "24hr Volume",
                                value: viewModel.volume,
                                percentageChange: nil
                            )
                            StatView(
                                title: "Coin Dominance",
                                value: viewModel.dominance,
                                percentageChange: nil
                            )
                             */
                        }
                        .padding(.horizontal, 24) // Increased padding to center content better
                        .multilineTextAlignment(.center)
                        
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                                .padding(.leading, 10)
                            
                            ZStack(alignment: .leading) {
                                if searchText.isEmpty {
                                    Text("Search")
                                        .foregroundColor(.black)
                                        .padding(.leading, 5)
                                }
                                TextField("", text: $searchText)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .foregroundColor(.black) // Text color
                                    .padding(.leading, 5)
                            }
                        }
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 25)
                            .fill(Color(.systemGray5)) // Updated background to light grey color
                            .shadow(color: .white.opacity(0.15), radius: 10, x: 0, y: 0))
                        .padding(.horizontal, 6)
                        
                        // Header Row
                        HStack {
                            Text("Coins")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            //Spacer()
                            
                            Text("Holdings")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            
                            HStack {
                                Text("Prices")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                // Refresh button
                                Button(action: {
                                    viewModel.fetchCryptoData() // Refreshes the crypto data
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(.white)
                                        .padding(.leading, 8)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal)
                        
                        // Coin List
                        ScrollView {
                            //VStack(alignment: .leading, spacing: 20) {
                              //  ForEach(filteredCoins, id: \.id) { coin in
                              //      NavigationLink(
                               //         destination: CryptoDetailView(
                                //            viewModel: CryptoDetailViewModel(coin: coin)
                                //        )
                                //    ) {
                               //         CoinRowView(coin: coin)
                               //     }
                              //  }
                            //}
                            //.padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    //.padding(.top, 50)
                }
            }
            
            }
        .tabItem{
            Image(systemName: "briefcase")
            Text("Portfolio")
        }// view ends
        
    }
}

struct CoinRowViewPortfolio: View {
    var coin: CoinGeckoCoin

    var body: some View {
        HStack {
            Text("\(coin.rank).")
                .foregroundColor(.white)

            AsyncImage(url: URL(string: coin.image)) { image in
                image
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
                    .frame(width: 30, height: 30)
            }

            Text(coin.symbol.uppercased())
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold)) // Bold font for coin names

            //Spacer()
            
                

            VStack(alignment: .trailing) {
                Text("$\(coin.current_price, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("\(coin.price_change_percentage_24h, specifier: "%.2f")%")
                    .foregroundColor(coin.price_change_percentage_24h < 0 ? .red : .green)
                    .font(.system(size: 14, weight: .bold))
            }
        }
        .padding(.vertical, 8)
    }
}

struct StatViewPortfolio: View {
    var title: String
    var value: String
    var percentageChange: String?

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium))

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            if let percentageChange = percentageChange {
                Text(percentageChange)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(percentageChange.contains("-") ? .red : .green)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

struct StatView_Previews_Portfolio: PreviewProvider {
    static var previews: some View {
        StatView(title: "Market Cap", value: "$1.24Tr", percentageChange: "-15.2%")
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}


#Preview {
    PortfolioView()
}

