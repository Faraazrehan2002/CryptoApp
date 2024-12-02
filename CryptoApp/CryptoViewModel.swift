import SwiftUI
import Combine

class CryptoViewModel: ObservableObject {
    @Published var coins: [CoinGeckoCoin] = []  // All available coins
    @Published var marketCap: String = ""  // Market Cap
    @Published var volume: String = ""  // 24h volume
    @Published var dominance: String = ""  // Dominance of top coin in portfolio
    @Published var marketCapPercentageChange: String = ""  // Market Cap % change
    @Published var portfolioCoins: [CoinGeckoCoin] = []  // Portfolio coins with holdings
    @Published var portfolioVolume: String = ""  // Volume for only portfolio coins             NEW CODE
    
    private var cancellables = Set<AnyCancellable>()  // For Combine publishers
    private let apiURL = "https://api.coingecko.com/api/v3"
    private let portfolioKey = "portfolioCoins"  // Key for storing portfolio data in UserDefaults
    
    // Portfolio value computed by summing up the current value of all holdings
    var portfolioValue: String {
        let totalValue = portfolioCoins.reduce(0) { $0 + $1.currentHoldingsValue }
        return String(format: "$%.2f", totalValue)
    }
    
    // Function to delete a coin from the portfolio
//        func deleteCoin(_ coin: CoinGeckoCoin) {
//            // Remove the coin from the portfolio
//            if let index = portfolioCoins.firstIndex(where: { $0.id == coin.id }) {
//                portfolioCoins.remove(at: index)
//            }
//            
//            // Update the portfolio volume
//            portfolioVolume = calculatedPortfolioVolume
//        }
    
    var calculatedPortfolioVolume: String {                                             //NEW CODE
        let totalVolume = portfolioCoins.reduce(0) { $0 + $1.total_volume }
        return formatLargeNumber(String(totalVolume))
    }
    
    // Top holding dominance: Dominance of the coin with the largest value in the portfolio
    var topHoldingDominance: String {
        let totalPortfolioValue = portfolioCoins.reduce(0) { $0 + $1.currentHoldingsValue }

        // Ensure totalPortfolioValue is greater than 0 to avoid division by zero
        guard totalPortfolioValue > 0,
              let topHolding = portfolioCoins.max(by: { $0.currentHoldingsValue < $1.currentHoldingsValue }) else {
            return "N/A"
        }

        // Calculate dominance as a percentage of the total portfolio value
        let dominanceValue = (topHolding.currentHoldingsValue / totalPortfolioValue) * 100
        return String(format: "%.2f%%", dominanceValue)
    }
    
    // API Key Handling (Optional if using API Key)
    var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let key = plist["API_KEY"] as? String else {
            fatalError("API Key not found in Secrets.plist")
        }
        return key
    }
    
    init() {
        fetchCryptoData()
        fetchGlobalData()
        loadPortfolio()
    }
    
    // Fetch coin data from CoinGecko API
    func fetchCryptoData() {
        var components = URLComponents(string: "\(apiURL)/coins/markets")!
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "sparkline", value: "true"),
            URLQueryItem(name: "x_cg_demo_api_key", value: apiKey)
        ]
        
        guard let url = components.url else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["accept": "application/json"]
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [CoinGeckoCoin].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Successfully fetched coin data.")
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] coins in
                self?.coins = coins
                self?.updatePortfolioAfterCoinFetch()
            })
            .store(in: &cancellables)
    }
    
    // Fetch global market data using the structure in `MarketDataModel`
    func fetchGlobalData() {
        guard let url = URL(string: "\(apiURL)/global") else {
            print("Invalid URL for global data.")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: GlobalData.self, decoder: JSONDecoder())  // Decode the GlobalData model
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Successfully fetched global data.")
                case .failure(let error):
                    print("Error fetching global data: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] marketDataModel in
                if let marketData = marketDataModel.data {  // Safely unwrap marketData
                    self?.marketCap = self?.formatLargeNumber(marketData.marketCap) ?? ""
                    self?.volume = self?.formatLargeNumber(marketData.volume) ?? ""
                    self?.dominance = marketData.btcDominance
                    self?.marketCapPercentageChange = String(format: "%.2f%%", marketData.marketCapChangePercentage24HUsd)
                }
            })
            .store(in: &cancellables)
    }

    
    // Format large numbers for display (e.g., $1.24Bn)
    func formatLargeNumber(_ numberString: String) -> String {
        guard let number = Double(numberString) else { return numberString }
        
        if number >= 1_000_000_000_000 {
            return String(format: "$%.2fTr", number / 1_000_000_000_000)
        } else if number >= 1_000_000_000 {
            return String(format: "$%.2fBn", number / 1_000_000_000)
        } else if number >= 1_000_000 {
            return String(format: "$%.2fM", number / 1_000_000)
        } else {
            return String(format: "$%.2f", number)
        }
    }
    
    // Save portfolio to UserDefaults
    func savePortfolio() {
        let portfolioDict = portfolioCoins.reduce(into: [String: Double]()) { result, coin in
            if let holdings = coin.currentHoldings {
                result[coin.id] = holdings
            }
        }
        UserDefaults.standard.set(portfolioDict, forKey: portfolioKey)
    }

    // Load portfolio from UserDefaults
    func loadPortfolio() {
        if let savedPortfolio = UserDefaults.standard.dictionary(forKey: portfolioKey) as? [String: Double] {
            portfolioCoins = savedPortfolio.compactMap { (id, holdings) in
                if let coin = coins.first(where: { $0.id == id }) {
                    return coin.updateHoldings(amount: holdings)
                }
                return nil
            }
        }
    }
    
   
    
    private func updatePortfolioAfterCoinFetch() {
        if let savedPortfolio = UserDefaults.standard.dictionary(forKey: portfolioKey) as? [String: Double] {
            portfolioCoins = coins.compactMap { coin in
                if let holdings = savedPortfolio[coin.id] {
                    return coin.updateHoldings(amount: holdings)
                }
                return nil
            }
            portfolioVolume = calculatedPortfolioVolume  // Update the portfolio volume here
        }
    }
    
   
    
    func updatePortfolio(with coin: CoinGeckoCoin, amount: Double) {
        if let index = portfolioCoins.firstIndex(where: { $0.id == coin.id }) {
            portfolioCoins[index] = coin.updateHoldings(amount: amount)  // Update existing coin
        } else {
            let updatedCoin = coin.updateHoldings(amount: amount)
            portfolioCoins.append(updatedCoin)  // Add new coin to portfolio
        }
        savePortfolio()  // Save the updated portfolio to UserDefaults
        portfolioVolume = calculatedPortfolioVolume  // Update portfolio volume
    }
    
    
    
}


// CoinGeckoCoin struct including holdings
struct CoinGeckoCoin: Decodable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let current_price: Double
    let market_cap: Double
    let market_cap_rank: Double?
    let total_volume: Double
    let high24h: Double?
    let low24h: Double?
    let price_change_percentage_24h: Double
    let price_change_24h: Double
    let marketCapChange24h: Double
    let marketCapChangePercentage24h: Double
    let lastUpdated: String
    let sparkline_in_7d: Sparkline
    let currentHoldings: Double?  // To store user's holdings for the coin
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case current_price = "current_price"
        case market_cap = "market_cap"
        case market_cap_rank = "market_cap_rank"
        case total_volume = "total_volume"
        case high24h = "high_24h"
        case low24h = "low_24h"
        case price_change_percentage_24h = "price_change_percentage_24h"
        case price_change_24h = "price_change_24h"
        case marketCapChange24h = "market_cap_change_24h"
        case marketCapChangePercentage24h = "market_cap_change_percentage_24h"
        case lastUpdated = "last_updated"
        case sparkline_in_7d = "sparkline_in_7d"
        case currentHoldings
    }
    
    // Method to update holdings
    func updateHoldings(amount: Double) -> CoinGeckoCoin {
        return CoinGeckoCoin(
            id: id,
            symbol: symbol,
            name: name,
            image: image,
            current_price: current_price,
            market_cap: market_cap,
            market_cap_rank: market_cap_rank,
            total_volume: total_volume,
            high24h: high24h,
            low24h: low24h,
            price_change_percentage_24h: price_change_percentage_24h,
            price_change_24h: price_change_24h,
            marketCapChange24h: marketCapChange24h,
            marketCapChangePercentage24h: marketCapChangePercentage24h,
            lastUpdated: lastUpdated,
            sparkline_in_7d: sparkline_in_7d,
            currentHoldings: amount
        )
    }
    
    // Current holdings value
    var currentHoldingsValue: Double {
        return (currentHoldings ?? 0) * current_price
    }
    
    var rank: Int {
        return Int(market_cap_rank ?? 0)
    }
    
    // Sparkline data for the last 7 days
    struct Sparkline: Decodable {
        let price: [Double]
    }
    
    struct GlobalData: Codable {
        let data: MarketData
        
        struct MarketData: Codable {
            let marketCap: Double
            let volume: Double
            let btcDominance: Double
            let marketCapChangePercentage24HUsd: Double
            
            enum CodingKeys: String, CodingKey {
                case marketCap = "total_market_cap"
                case volume = "total_volume"
                case btcDominance = "btc_dominance"
                case marketCapChangePercentage24HUsd = "market_cap_change_percentage_24h_usd"
            }
        }
    }
    
    
}


