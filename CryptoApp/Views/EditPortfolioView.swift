import SwiftUI

struct EditPortfolioView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CryptoViewModel
    @State private var selectedCoin: CoinGeckoCoin? = nil
    @State private var quantityText: String = ""
    @State private var searchText = ""
    @State private var isLandscape: Bool = false // State to track orientation

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
        ScrollView {
            VStack(spacing: 20) {
                header
                title
                searchBar
                coinScrollView

                if let selectedCoin = selectedCoin {
                    coinDetails
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#851439"),
                    Color(hex: "#151E52")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .onAppear {
            updateOrientation()
            NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                updateOrientation()
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(
                self,
                name: UIDevice.orientationDidChangeNotification,
                object: nil
            )
        }
    }

    private func updateOrientation() {
        isLandscape = UIDevice.current.orientation.isLandscape
    }

    // Header with Back and Done buttons
    private var header: some View {
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
            Spacer()
            Button(action: {
                if let selectedCoin = selectedCoin, let amount = Double(quantityText) {
                    viewModel.updatePortfolio(with: selectedCoin, amount: amount)
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .opacity(
                (selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantityText)) ? 1.0 : 0.0
            )
        }
        .padding()
    }

    // Title
    private var title: some View {
        Text("Edit Portfolio")
            .font(Font.custom("Poppins-Bold", size: 32))
            .foregroundColor(.white)
            .padding(.top, isLandscape ? 0 : 10) // Adjust padding for portrait/landscape
    }

    // Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.black)
                .padding(.leading, 10)

            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Search")
                        .font(Font.custom("Poppins-Medium", size: 16))
                        .foregroundColor(.black)
                }
                TextField("", text: $searchText)
                    .font(Font.custom("Poppins-Medium", size: 16))
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
    }

    // Coin Selection ScrollView
    private var coinScrollView: some View {
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
                            .font(Font.custom("Poppins-Bold", size: 16))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

                        Text(coin.name)
                            .font(Font.custom("Poppins-Medium", size: 16))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .onTapGesture {
                        withAnimation(.easeIn) {
                            selectedCoin = coin
                            // Set the text to be empty instead of showing 0.0
                            quantityText = coin.currentHoldings == nil ? "" : "\(coin.currentHoldings!)"
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
    }

    // Selected Coin Details
    private var coinDetails: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Current Price of \(selectedCoin?.symbol.uppercased() ?? ""):")
                    .font(Font.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                Spacer()
                Text(selectedCoin?.current_price.asCurrencyWith6Decimals() ?? "")
                    .font(Font.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.white)
            }
            .padding()

            Divider()
                .background(Color.white)
                .padding()

            HStack {
                Text("Amount Holding:")
                    .font(Font.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                Spacer()
                ZStack(alignment: .trailing) {
                    if quantityText.isEmpty {
                        Text("Enter amount") // Adjusted placeholder text
                            .foregroundColor(Color.white.opacity(0.6)) // Contrasting color for visibility
                            .font(Font.custom("Poppins-Medium", size: 16))
                            .padding(.trailing, 10)
                    }
                    TextField("", text: $quantityText)
                        .font(Font.custom("Poppins-Medium", size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .keyboardType(.decimalPad)
                        .onTapGesture {
                            if quantityText == "0.0" { // Clear placeholder when tapped
                                quantityText = ""
                            }
                        }
                }
            }
            .padding()


            Divider()
                .background(Color.white)
                .padding()

            HStack {
                Text("Current Value:")
                    .font(Font.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                Spacer()
                Text(getCurrentValue().asCurrencyWith2Decimals())
                    .font(Font.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.white)
            }
            .padding()
        }
    }

    func getCurrentValue() -> Double {
        if let quantity = Double(quantityText) {
            return quantity * (selectedCoin?.current_price ?? 0)
        }
        return 0
    }
}

#Preview {
    EditPortfolioView(viewModel: CryptoViewModel())
}
