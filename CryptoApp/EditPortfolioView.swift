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
            return viewModel.coins
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
                    Color(hex: "#851439"),
                    Color(hex: "#151E52")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .opacity(
                        (selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantityText)) ? 1.0 : 0.0)
                }
                
                Text("Edit Portfolio")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                    
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text("Search")
                                .foregroundColor(.black)
                        }
                        TextField("", text: $searchText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.black)
                            .padding(.leading, 5)
                    }
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(color: .white.opacity(0.15), radius: 10, x: 0, y: 0))
                .padding(.horizontal, -10)
                
                // ScrollView placed directly below the search bar with minimal spacing
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
                                    .fill(Color.white.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(selectedCoin?.id == coin.id ? Color.white : Color.clear, lineWidth: 2)
                            )
                            .frame(width: 100, height: 150)
                        }
                    }
                }
                .padding(.top, 8) // Slight padding to ensure scroll view is just under the search bar
                
                // If a coin is selected, show details
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
                        
                        HStack {
                            Text("Amount Holding:")
                                .foregroundColor(.white)
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
                        
                        HStack {
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
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func getCurrentValue() -> Double {
        if let quantity = Double(quantityText) {
            return quantity * (selectedCoin?.current_price ?? 0)
        }
        return 0
    }
    
    
    
}

#Preview {
    EditPortfolioView()
}
