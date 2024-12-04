import SwiftUI

struct PortfolioView: View {
    @ObservedObject var viewModel: CryptoViewModel

    @State private var searchText = ""
    @State private var isPriceSortAscending = true

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
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#851439"), Color(hex: "#151E52")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

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
                .font(.largeTitle)
                .fontWeight(.bold)
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
                percentageChange: "2.30"
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
                        .foregroundColor(.black)
                        .padding(.leading, 5)
                }
                TextField("", text: $searchText)
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
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Text("Holdings")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            Button(action: { isPriceSortAscending.toggle() }) {
                HStack {
                    Text("Prices")
                        .font(.system(size: 18, weight: .bold))
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
}

// CoinRowViewPortfolio
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
                .foregroundColor(.white)
                .font(.headline)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(coin.currentHoldingsValue.formatLargeNumber())")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(coin.currentHoldings ?? 0, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(coin.current_price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(coin.price_change_percentage_24h, specifier: "%.2f")%")
                    .foregroundColor(coin.price_change_percentage_24h < 0 ? .red : .green)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }
}

struct PortfolioStatView: View {
    var title: String
    var value: String
    var isCurrency: Bool = false
    var percentageChange: String?

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium))

            // Ensure only one dollar sign
            Text(isCurrency ? "\(value.contains("$") ? value : "$\(value)")" : value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1) // Prevents wrapping
                .minimumScaleFactor(0.8) // Adjusts the text size if needed

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
