import SwiftUI
import Combine

class CryptoViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var marketCap: String = ""
    @Published var volume: String = ""
    @Published var dominance: String = ""
    
    private var cancellable: AnyCancellable?
    
    private let apiURL = "https://api.coingecko.com/api/v3"
    
    // Load the API key from Secrets.plist
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
        // Construct the URL using URLComponents
        var components = URLComponents(string: "\(apiURL)/coins/markets")!
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "sparkline", value: "true"),
            URLQueryItem(name: "x_cg_demo_api_key", value: apiKey) // Pass the API key as a query parameter
        ]
        
        // Ensure the URL is valid
        guard let url = components.url else {
            print("Invalid URL")
            return
        }
        
        // Print the constructed URL for debugging
        print("Fetching data from URL: \(url)")
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10 // Optional: Add timeout interval for the request
        request.allHTTPHeaderFields = ["accept": "application/json"] // Optional: Specify any additional headers
        
        // Perform the network request using Combine
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                // Ensure the response is an HTTP response and check for successful status code
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
                
                // Map the API data to the local Coin model
                self?.coins = coins.map { Coin(rank: $0.market_cap_rank, symbol: $0.symbol.uppercased(), imageName: $0.image, price: "$\($0.current_price)", change: "\($0.price_change_percentage_24h)%", sparkline: $0.sparkline_in_7d) }
                
                // Update the summary statistics for market cap, volume, and dominance
                self?.marketCap = "$\(String(format: "%.2f", coins.reduce(0) { $0 + $1.market_cap } / 1_000_000_000))Bn"
                self?.volume = "$\(String(format: "%.2f", coins.reduce(0) { $0 + $1.total_volume } / 1_000_000_000))Bn"
                self?.dominance = "\(String(format: "%.2f", (coins.first?.market_cap ?? 0) / coins.reduce(0) { $0 + $1.market_cap } * 100))%"
            })
    }
}

struct CoinGeckoCoin: Decodable {
    let id: String
    let symbol: String
    let current_price: Double
    let market_cap: Double
    let total_volume: Double
    let price_change_percentage_24h: Double
    let market_cap_rank: Int
    let image: String // Image URL
    let sparkline_in_7d: Sparkline
    
    struct Sparkline: Decodable {
        let price: [Double]
    }
}


struct Coin: Identifiable {
    let id = UUID()
    let rank: Int
    let symbol: String
    let imageName: String
    let price: String
    let change: String
    let sparkline: CoinGeckoCoin.Sparkline
}
