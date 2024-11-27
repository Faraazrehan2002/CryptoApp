import SwiftUI
import Charts

struct HomeView: View {
    @ObservedObject var viewModel = CryptoViewModel()
    
    @EnvironmentObject var vm: CryptoViewModel

    @State private var showPortfolio: Bool = false
    @State private var showPortfolioView: Bool = false
    @State private var searchText = ""
    
    @State private var isCoinSortAscending: Bool = false
    @State private var isPriceSortAscending: Bool = false
    @State private var navigateToNews: Bool = false

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
        
        if isCoinSortAscending {
            return coinsToDisplay.sorted { $0.rank > $1.rank }
        } else if isPriceSortAscending {
            return coinsToDisplay.sorted { $0.current_price < $1.current_price }
        } else {
            return coinsToDisplay.sorted { $0.rank < $1.rank }
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
                    
                    // Header Row
                    HStack {
                        // Coin Sort Button
                        Button(action: {
                            isCoinSortAscending.toggle()
                            isPriceSortAscending = false
                        }) {
                            HStack {
                                Text("Coins")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                Image(systemName: "arrow.up.arrow.down")
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Button(action: {
                                isPriceSortAscending.toggle()
                                isCoinSortAscending = false
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
                            
                            // Refresh button
                            Button(action: {
                                viewModel.fetchCryptoData()
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
                                            .padding(.horizontal)
                                        }

                                        Spacer()
                                    }
                                    .padding(.top, 50)
                                    .gesture(
                                        DragGesture()
                                            .onEnded { value in
                                                if value.translation.width > 100 {
                                                    withAnimation(.easeInOut){
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
                            }
                            .tabItem {
                                Image(systemName: "house")
                                Text("Home")
                            }
                        }
                    }

struct CoinRowView: View {
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

/*
struct StatView_Previews: PreviewProvider {
    static var previews: some View {
        StatView(title: "Market Cap", value: "$1.24Tr", percentageChange: "-15.2%")
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}*/

#Preview {
    HomeView().environmentObject(CryptoViewModel())
}
