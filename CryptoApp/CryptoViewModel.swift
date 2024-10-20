import SwiftUI
import Combine

class CryptoViewModel: ObservableObject {
    @Published var coins: [CoinGeckoCoin] = []
    @Published var marketCap: String = ""
    @Published var volume: String = ""
    @Published var dominance: String = ""
    @Published var marketCapPercentageChange: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    private let apiURL = "https://api.coingecko.com/api/v3"
    
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
        fetchGlobalData()  // Ensure this gets called to retrieve the market cap and dominance
    }
    
    // Fetch coin data
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
        
        print("Fetching coin data from URL: \(url)")
        
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
            })
            .store(in: &cancellables)
    }
    
    // Fetch global market data
    func fetchGlobalData() {
        guard let url = URL(string: "\(apiURL)/global") else {
            print("Invalid URL for global data.")
            return
        }
        
        print("Fetching global data from URL: \(url)")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: GlobalData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Successfully fetched global data.")
                case .failure(let error):
                    print("Error fetching global data: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] globalData in
                guard let marketData = globalData.data else {
                    print("No data in global data response.")
                    return
                }
                
                print("Global data retrieved: \(marketData)")
                
                self?.marketCap = self?.formatLargeNumber(marketData.marketCap) ?? ""
                self?.volume = self?.formatLargeNumber(marketData.volume) ?? ""
                self?.dominance = marketData.btcDominance
                self?.marketCapPercentageChange = String(format: "%.2f%%", marketData.marketCapChangePercentage24HUsd)
                
                print("Formatted Market Cap: \(self?.marketCap ?? "")")
                print("Formatted Volume: \(self?.volume ?? "")")
                print("Formatted BTC Dominance: \(self?.dominance ?? "")")
            })
            .store(in: &cancellables)
    }
    
    // Format large numbers for display
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
}


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
    let currentHoldings: Double?
    
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
    
    func updateHoldings(amount: Double) -> CoinGeckoCoin {
        
        return CoinGeckoCoin(id: id, symbol: symbol, name: name, image: image, current_price: current_price, market_cap: market_cap, market_cap_rank: market_cap_rank, total_volume: total_volume, high24h: high24h, low24h: low24h, price_change_percentage_24h: price_change_percentage_24h, price_change_24h: price_change_24h, marketCapChange24h: marketCapChange24h, marketCapChangePercentage24h: marketCapChangePercentage24h, lastUpdated: lastUpdated, sparkline_in_7d: sparkline_in_7d, currentHoldings: amount)
        
    }
    var currentHoldingsValue: Double {
        return (currentHoldings ?? 0) * current_price
    }
    var rank: Int {
        return Int(market_cap_rank ?? 0)
    }
    
    struct Sparkline: Decodable {
        let price: [Double]
    }

    
    
}
