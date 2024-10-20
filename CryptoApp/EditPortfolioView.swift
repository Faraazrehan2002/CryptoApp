//
//  EditPortfolioView.swift
//  CryptoApp
//
//  Created by Andrew Guzman on 10/2/24.
//

import SwiftUI

struct EditPortfolioView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedCoin: CoinGeckoCoin? = nil
    
    @ObservedObject var viewModel = CryptoViewModel()
    
    @State private var quantityText: String = ""

    @State private var searchText = ""
    
    @State private var showDone: Bool = false
    
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
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Action to go back
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                            Text("Back")
                                .font(.headline) // Adjust weight
                                .foregroundColor(.white) // Adjust color
                        }
                    }
                    .padding()

                    Spacer()
//Button Start
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Action to go back to PortfolioView
                    }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .opacity(
                        (selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantityText)) ? 1.0 : 0.0)
                    .padding()
                }

                Text("Edit Portfolio")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

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

                // ScrollView placed right below the search bar
                ScrollView(.horizontal, showsIndicators: true) {
                    LazyHStack(spacing: 20) {
                        ForEach(filteredCoins, id: \.id) { coin in
                            VStack {
                                AsyncImage(url: URL(string: coin.image)) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProgressView()
                                }
                                
                                Text(coin.symbol.uppercased())
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            
                                Text(coin.name)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding()
                            .onTapGesture {
                                withAnimation(.easeIn) {
                                    selectedCoin = coin
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.1))  // Background fill color
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(selectedCoin?.id == coin.id ? Color.white : Color.clear, lineWidth: 2)
                            )
                            .frame(width: 100, height: 150)
                        }
                    }
                }
                .padding(.top, -380) // Adjusts the position slightly below the search bar

                // Current Price text right below ScrollView, without too much spacing
                if let selectedCoin = selectedCoin {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Current Price of \(selectedCoin.symbol.uppercased()):")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding(.top)
                            
                            Spacer()
                            Text(selectedCoin.current_price.asCurrencyWith6Decimals())
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding(.top)
                        }
                        .padding()
                        
                        Divider()
                            .background(Color.white)
                            .padding()
                        
                        HStack{
                            
                        Text("Amount Holding:")
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .font(.headline)
                        Spacer()
                            TextField("Ex: 1.4", text: $quantityText)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                                .padding(10)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .keyboardType(.decimalPad)
                                .font(.headline)
                        }
                        .padding()
                        
                        Divider()
                            .background(Color.white)
                            .padding()
                        
                        HStack{
                            
                            Text("Current Value:")
                                .foregroundColor(.white)
                                .font(.headline)
                            Spacer()
                            Text(getCurrentValue().asCurrencyWith2Decimals())
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        
                        .padding()
                    }
                    .padding(.top, -400)
                }
                    
                //Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func getCurrentValue() -> Double{
        if let quantity = Double(quantityText){
            return quantity * (selectedCoin?.current_price ?? 0)
        }
        return 0
    }
    
}

#Preview {
    EditPortfolioView()
}
