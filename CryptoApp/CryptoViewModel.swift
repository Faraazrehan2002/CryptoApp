import SwiftUI
import Combine

class CryptoViewModel: ObservableObject {
    @Published var coins: [CoinGeckoCoin] = []
    @Published var marketCap: String = ""
    @Published var volume: String = ""
    @Published var dominance: String = ""
    @Published var marketCapPercentageChange: String = "" // Add this for percentage change
    @Published var dominancePercentageChange: String = ""
    
    private var cancellable: AnyCancellable?
    
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
    }
    
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
        
        print("Fetching data from URL: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]
        
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Response Code: \(httpResponse.statusCode)")
                }
                
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
                    print("Successfully fetched data.")
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] coins in
                print("Received \(coins.count) coins.")
                
                self?.coins = coins // Assign directly
                
                // Update the summary statistics
                self?.marketCap = "$\(String(format: "%.2f", coins.reduce(0) { $0 + $1.market_cap } / 1_000_000_000))Bn"
                self?.volume = "$\(String(format: "%.2f", coins.reduce(0) { $0 + $1.total_volume } / 1_000_000_000))Bn"
                self?.dominance = "\(String(format: "%.2f", (coins.first?.market_cap ?? 0) / coins.reduce(0) { $0 + $1.market_cap } * 100))%"
            })
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
