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
    
    @EnvironmentObject var vm: HomeViewModel

    @State private var showPortfolio: Bool = false
    
    
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
    
    enum SortOption{
        case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
        
        
    }
    
    
    var body: some View {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#851439"),
                        Color(hex: "#151E52")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Live Prices")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    HStack(alignment: .top, spacing: 36) {
                        StatView(
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
                            percentageChange: viewModel.dominancePercentageChange
                        )
                    }
                    .padding()
                    .multilineTextAlignment(.center)


                    // Search bar
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
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                
                        }
                    }
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(color: .white.opacity(0.15), radius: 10, x: 0, y: 0))
                    .padding(.horizontal, 6)
                     
                    HStack {
                        Text("Coin")
                        Spacer()
                        Text("Price")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                    // ScrollView to display filtered coins
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(filteredCoins, id: \.id) { coin in
                                CoinRowView(coin: coin, showHoldingsColumn: false)
                            }
                        }
                        .padding(.horizontal)
                    }

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
    var coin: CoinGeckoCoin
    let showHoldingsColumn: Bool

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Text("\(coin.rank).")
                    .foregroundColor(.white)

                // Use AsyncImage to load the image from the URL
                AsyncImage(url: URL(string: coin.image)) { image in
                    image
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                } placeholder: {
                    
                    ProgressView()
                        .frame(width: 30, height: 30)
                }

                Text(coin.symbol.uppercased()) // Ensure symbol is uppercase
                    .foregroundColor(.white)
            }

            Spacer()
            
            if showHoldingsColumn{
                VStack(alignment: .trailing){
                    Text(coin.currentHoldingsValue.asCurrencyWith2Decimals())
                        .fontWeight(.bold)
                    
                    Text((coin.currentHoldings ?? 0).asNumberString())
                }
                .foregroundColor(.white)
                
            }
            
            VStack(alignment: .trailing) {
                Text(coin.current_price.asCurrencyWith6Decimals())
                    .foregroundColor(.white)
                    .fontWeight(.bold)

                Text(coin.price_change_percentage_24h.asPercentString())
                    .foregroundColor(coin.price_change_percentage_24h < 0 ? .red : .green)
                    .font(.subheadline)
            }
            .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }
}


struct StatView: View {
    var title: String
    var value: String
    var percentageChange: String?

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .foregroundColor(.white)
                .font(.caption)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                if let percentageChange = percentageChange,
                   let percentageValue = Double(percentageChange.trimmingCharacters(in: CharacterSet(charactersIn: "%"))) {
                    
                    Image(systemName: "triangle.fill")
                        .font(.caption)
                        .foregroundColor(percentageValue >= 0 ? .green : .red)
                        .rotationEffect(Angle(degrees: percentageValue >= 0 ? 0 : 180))
                    
                    Text(percentageChange)
                        .font(.caption)
                        .bold()
                        .foregroundColor(percentageValue >= 0 ? .green : .red)
                }
            }
        }
    }
}





struct StatView_Previews: PreviewProvider {
    static var previews: some View {
        StatView(title: "Market Cap", value: "$1.24Tr", percentageChange: "-15.2%")
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}



#Preview {
    HomeView()
}
