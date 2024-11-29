import SwiftUI

struct PortfolioView: View {
    @ObservedObject var viewModel: CryptoViewModel
    
    @State private var searchText = ""
    @State private var isCoinSortAscending = true
    @State private var isPriceSortAscending = true
    @State private var isLandscape: Bool = false // Track orientation

    // Filtered coins
    var filteredCoins: [CoinGeckoCoin] {
        let addedCoins = viewModel.portfolioCoins.filter { $0.currentHoldings != nil && $0.currentHoldings! > 0 }
        
        let coins = searchText.isEmpty ? addedCoins : addedCoins.filter { coin in
            coin.name.localizedCaseInsensitiveContains(searchText) || coin.symbol.localizedCaseInsensitiveContains(searchText)
        }
        
        let sortedCoins = coins.sorted { (coin1, coin2) -> Bool in
            if isCoinSortAscending {
                return coin1.symbol < coin2.symbol
            } else {
                return coin1.symbol > coin2.symbol
            }
        }.sorted { (coin1, coin2) -> Bool in
            if isPriceSortAscending {
                return coin1.current_price < coin2.current_price
            } else {
                return coin1.current_price > coin2.current_price
            }
        }
        
        return sortedCoins
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

                if isLandscape {
                    // Unified vertical layout for landscape mode
                    ScrollView {
                        VStack(spacing: 10) {
                            header
                            title
                            stats
                            searchBar
                            sortingHeader
                            coinList
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // Original portrait layout
                    VStack(spacing: 10) {
                        header
                        title
                        stats
                        searchBar
                        sortingHeader
                        coinList
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
        }
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
        .tabItem {
            Image(systemName: "briefcase")
            Text("Portfolio")
        }
    }

    private func updateOrientation() {
        isLandscape = UIDevice.current.orientation.isLandscape
    }

    // Header with edit button
    private var header: some View {
        HStack {
            NavigationLink(destination: EditPortfolioView(viewModel: viewModel)) {
                Image(systemName: "pencil")
                    .foregroundColor(.white)
                    .font(.title)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // Title
    private var title: some View {
        Text("Portfolio")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.top, 3.5)
    }

    // Stats Section
    private var stats: some View {
        HStack(alignment: .top, spacing: 31) {
            PortfolioStatView(
                title: "Portfolio Value",
                value: viewModel.portfolioValue,
                percentageChange: "2.30"
            )
            PortfolioStatView(
                title: "24hr Volume",
                value: viewModel.portfolioVolume,
                percentageChange: nil
            )
            PortfolioStatView(
                title: "Top Holding Dominance",
                value: viewModel.topHoldingDominance,
                percentageChange: nil
            )
        }
        .padding(.horizontal, 24)
        .multilineTextAlignment(.center)
        .padding(.top, 10)
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
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 25).fill(Color(.systemGray5)))
        .padding(.horizontal, 6)
    }

    // Sorting Header
    private var sortingHeader: some View {
        HStack {
            Button(action: {
                isCoinSortAscending.toggle()
            }) {
                HStack {
                    Text("Coins")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("Holdings")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Button(action: {
                isPriceSortAscending.toggle()
            }) {
                HStack {
                    Text("Prices")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // Coin List
    private var coinList: some View {
        List {
            ForEach(filteredCoins, id: \.id) { coin in
                CoinRowViewPortfolio(coin: coin)
                    .listRowBackground(Color.clear)
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.deleteCoin(coin)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
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
                .font(.system(size: 16, weight: .bold))

            Spacer()

            VStack(alignment: .trailing) {
                Text("$\(coin.currentHoldingsValue, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("\(coin.currentHoldings ?? 0, specifier: "%.2f")")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()

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
        .background(Color.clear)
    }
}

// PortfolioStatView
struct PortfolioStatView: View {
    var title: String
    var value: String
    var percentageChange: String?

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium))

            Text(value)
                .font(.system(size: 16, weight: .bold))
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

#Preview {
    PortfolioView(viewModel: CryptoViewModel())
}

