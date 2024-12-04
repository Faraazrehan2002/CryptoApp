import SwiftUI
import Charts

struct HomeView: View {
    @ObservedObject var viewModel: CryptoViewModel
    @EnvironmentObject var vm: CryptoViewModel

    @State private var searchText = ""
    @State private var isPriceSortAscending: Bool = false
    @State private var navigateToNews: Bool = false
    @State private var isLandscape: Bool = false

    var filteredCoins: [CoinGeckoCoin] {
        var coinsToDisplay: [CoinGeckoCoin]
        if searchText.isEmpty {
            coinsToDisplay = viewModel.coins
        } else {
            coinsToDisplay = viewModel.coins.filter { coin in
                coin.name.localizedCaseInsensitiveContains(searchText) ||
                coin.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }

        if isPriceSortAscending {
            return coinsToDisplay.sorted { $0.current_price < $1.current_price }
        } else {
            return coinsToDisplay.sorted { $0.current_price > $1.current_price }
        }
    }

    var body: some View {
        NavigationView {
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
                    // Title
                    Text("Live Prices")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    // Stats Section
                    stats

                    // Search Bar
                    searchBar

                    // Heading and Sorting
                    HStack {
                        Text("Coins")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()

                        Button(action: {
                            isPriceSortAscending.toggle()
                        }) {
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

                    // Coin List
                    coinList

                    Spacer()
                }
                .padding(.horizontal)
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 100 {
                            withAnimation(.easeInOut) {
                                navigateToNews = true
                            }
                        }
                    }
            )
            .background(
                NavigationLink(
                    destination: CryptoNewsView()
                        .transition(.move(edge: .leading)),
                    isActive: $navigateToNews,
                    label: { EmptyView() }
                )
                .hidden()
            )
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
            Image(systemName: "house")
            Text("Home")
        }
    }

    private func updateOrientation() {
        isLandscape = UIDevice.current.orientation.isLandscape
    }

    // Stats Section
    private var stats: some View {
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
                title: "Top Coin Dominance",
                value: viewModel.dominance,
                percentageChange: nil
            )
        }
        .padding(.horizontal, 24)
        .multilineTextAlignment(.center)
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
        .background(RoundedRectangle(cornerRadius: 25)
            .fill(Color(.systemGray5))
            .shadow(color: .white.opacity(0.15), radius: 10, x: 0, y: 0))
        .padding(.horizontal, 6)
    }

    // Coin List
    private var coinList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(filteredCoins, id: \.id) { coin in
                    NavigationLink(
                        destination: CryptoDetailView(
                            viewModel: CryptoDetailViewModel(coin: coin)
                        )
                    ) {
                        CoinRowView(coin: coin)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// CoinRowView
struct CoinRowView: View {
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
                .font(.system(size: 16, weight: .bold))

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
    }
}

// StatView
struct StatView: View {
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
                .lineLimit(1) // Ensures the text stays on one line
                .minimumScaleFactor(0.5) // Scales down if the text is too long

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
    HomeView(viewModel: CryptoViewModel())
}
