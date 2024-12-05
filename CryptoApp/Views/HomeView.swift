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
        GeometryReader { geometry in
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

                    if isLandscape {
                        // Landscape Mode: Vertical Scroll Layout
                        ScrollView {
                            VStack(spacing: 20) {
                                title
                                stats
                                searchBar
                                sortingHeader

                                // Show all coins in landscape mode
                                ForEach(filteredCoins, id: \.id) { coin in
                                    NavigationLink(
                                        destination: CryptoDetailView(
                                            viewModel: CryptoDetailViewModel(coin: coin)
                                        )
                                    ) {
                                        CoinRowView(coin: coin)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: UIScreen.main.bounds.height * 0.8) 
                    } else {
                        // Portrait Mode: Original Layout
                        VStack(spacing: 20) {
                            title
                            stats
                            searchBar
                            sortingHeader
                            coinList
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
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
                updateOrientation(with: geometry.size)
            }
            .onChange(of: geometry.size) { newSize in
                updateOrientation(with: newSize)
            }
        }
    }

    // MARK: - Helper Views
    private var title: some View {
        Text("Live Prices")
            .font(Font.custom("Poppins-Bold", size: 36))
            .foregroundColor(.white)
            .padding(.top, isLandscape ? 10 : 20) // Adjust padding based on orientation
    }

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

    private var sortingHeader: some View {
        HStack {
            Text("Coins")
                .font(Font.custom("Poppins-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button(action: {
                isPriceSortAscending.toggle()
            }) {
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
    }

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

    private func updateOrientation(with size: CGSize) {
        isLandscape = size.width > size.height
    }
    
    struct StatView: View {
        var title: String
        var value: String
        var percentageChange: String?

        var body: some View {
            VStack(spacing: 8) {
                Text(title)
                    .font(Font.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.white)

                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

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
                    .font(Font.custom("Poppins-Bold", size: 16))

                Spacer()

                VStack(alignment: .trailing) {
                    Text("$\(coin.current_price, specifier: "%.2f")")
                        .font(Font.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.white)
                    Text("\(coin.price_change_percentage_24h, specifier: "%.2f")%")
                        .foregroundColor(coin.price_change_percentage_24h < 0 ? .red : .green)
                        .font(Font.custom("Poppins-Bold", size: 14))
                }
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    HomeView(viewModel: CryptoViewModel())
}
