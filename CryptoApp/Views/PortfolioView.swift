import SwiftUI

struct PortfolioView: View {
    @ObservedObject var viewModel: CryptoViewModel

    @State private var searchText = ""
    @State private var isPriceSortAscending = true
    @State private var isLandscape = false

    var filteredCoins: [CoinGeckoCoin] {
        let addedCoins = viewModel.portfolioCoins.filter { $0.currentHoldings != nil && $0.currentHoldings! > 0 }

        let coins = searchText.isEmpty ? addedCoins : addedCoins.filter { coin in
            coin.name.localizedCaseInsensitiveContains(searchText) || coin.symbol.localizedCaseInsensitiveContains(searchText)
        }

        return coins.sorted { (coin1, coin2) -> Bool in
            if isPriceSortAscending {
                return coin1.current_price < coin2.current_price
            } else {
                return coin1.current_price > coin2.current_price
            }
        }
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#851439"), Color(hex: "#151E52")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    if isLandscape {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                combinedHeaderAndTitle
                                stats
                                searchBar
                                sortingHeader
                                ForEach(filteredCoins, id: \.id) { coin in
                                    CoinRowViewPortfolio(coin: coin)
                                        .padding(.horizontal)
                                        .background(Color.clear)
                                }
                            }
                            .padding(.top, 10)
                        }
                    } else {
                        VStack(spacing: 10) {
                            combinedHeaderAndTitle
                            stats
                            searchBar
                            sortingHeader
                            coinList
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
                .onAppear {
                    updateOrientation(with: geometry.size)
                }
                .onChange(of: geometry.size) { newSize in
                    updateOrientation(with: newSize)
                }
            }
        }
        .tabItem {
            Image(systemName: "briefcase")
            Text("Portfolio")
        }
    }

    private var combinedHeaderAndTitle: some View {
        HStack {
            NavigationLink(destination: EditPortfolioView(viewModel: viewModel)) {
                Image(systemName: "pencil")
                    .foregroundColor(.white)
                    .font(.title)
            }

            Spacer()

            Text("Portfolio")
                .font(Font.custom("Poppins-Bold", size: 36))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.trailing, 30)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    private var stats: some View {
        HStack(alignment: .top, spacing: 31) {
            PortfolioStatView(
                title: "Portfolio Value",
                value: viewModel.portfolioValue,
                isCurrency: true,
                percentageChange: calculatePortfolioChange()
            )
            PortfolioStatView(
                title: "24hr Volume",
                value: viewModel.portfolioVolume,
                isCurrency: true
            )
            PortfolioStatView(
                title: "Top Holding Dominance",
                value: viewModel.topHoldingDominance,
                isCurrency: false
            )
        }
        .font(Font.custom("Poppins-Medium", size: 18))
        .padding(.horizontal, 24)
        .multilineTextAlignment(.center)
        .padding(.top, 10)
    }

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
                        .padding(.leading, 5)
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
        .background(RoundedRectangle(cornerRadius: 25).fill(Color(.systemGray5)))
        .padding(.horizontal, 6)
    }

    private var sortingHeader: some View {
        HStack {
            Text("Coins")
                .font(Font.custom("Poppins-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Text("Holdings")
                .font(Font.custom("Poppins-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            Button(action: { isPriceSortAscending.toggle() }) {
                HStack {
                    Text("Prices")
                        .font(Font.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.white)
                    Image(systemName: isPriceSortAscending ? "arrow.down" : "arrow.up")
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    private var coinList: some View {
        List {
            ForEach(filteredCoins, id: \.id) { coin in
                CoinRowViewPortfolio(coin: coin)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deleteCoin(coin)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(Color(red: 0.6, green: 0, blue: 0))
                    }
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }

    private func updateOrientation(with size: CGSize) {
        isLandscape = size.width > size.height
    }

    private func calculatePortfolioChange() -> String? {
        let coinsWithHoldings = viewModel.portfolioCoins.filter { $0.currentHoldings != nil && $0.currentHoldings! > 0 }

        guard !coinsWithHoldings.isEmpty else {
            return nil // Return nil if no coins in the portfolio
        }

        let totalValue = coinsWithHoldings.reduce(0.0) { $0 + ($1.currentHoldingsValue) }
        let weightedChange = coinsWithHoldings.reduce(0.0) { (sum, coin) in
            sum + (coin.currentHoldingsValue / totalValue) * (coin.price_change_percentage_24h)
        }

        return String(format: "%.2f%%", weightedChange) // Return the weighted average as a percentage
    }
}

// MARK: - CoinRowViewPortfolio
struct CoinRowViewPortfolio: View {
    var coin: CoinGeckoCoin

    var body: some View {
        HStack {
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
                .font(Font.custom("Poppins-Bold", size: 16))
                .foregroundColor(.white)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(coin.currentHoldingsValue.formatLargeNumber())")
                    .font(Font.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                Text("\(coin.currentHoldings ?? 0, specifier: "%.2f")")
                    .font(Font.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(coin.current_price, specifier: "%.2f")")
                    .font(Font.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                Text("\(coin.price_change_percentage_24h, specifier: "%.2f")%")
                    .font(Font.custom("Poppins-Bold", size: 16))
                    .foregroundColor(coin.price_change_percentage_24h < 0 ? .red : .green)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - PortfolioStatView
struct PortfolioStatView: View {
    var title: String
    var value: String
    var isCurrency: Bool = false
    var percentageChange: String?

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .foregroundColor(.white)
                .font(Font.custom("Poppins-Medium", size: 14))

            Text(isCurrency ? "\(value.contains("$") ? value : "$\(value)")" : value)
                .font(Font.custom("Poppins-Bold", size: 16))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if let percentageChange = percentageChange {
                Text(percentageChange)
                    .font(Font.custom("Poppins-Bold", size: 14))
                    .foregroundColor(percentageChange.contains("-") ? .red : .green)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

extension Double {
    func formatLargeNumber() -> String {
        if self >= 1_000_000_000_000 {
            return String(format: "%.2fT", self / 1_000_000_000_000)
        } else if self >= 1_000_000_000 {
            return String(format: "%.2fB", self / 1_000_000_000)
        } else if self >= 1_000_000 {
            return String(format: "%.2fM", self / 1_000_000)
        } else {
            return String(format: "%.2f", self)
        }
    }

    func formatLargeNumberWithoutDecimals() -> String {
        if self >= 1_000_000_000_000 {
            return String(format: "%.0fT", self / 1_000_000_000_000)
        } else if self >= 1_000_000_000 {
            return String(format: "%.0fB", self / 1_000_000_000)
        } else if self >= 1_000_000 {
            return String(format: "%.0fM", self / 1_000_000)
        } else {
            return String(format: "%.0f", self)
        }
    }
}

#Preview {
    PortfolioView(viewModel: CryptoViewModel())
}

