import SwiftUI
import Combine

class CryptoDetailViewModel: ObservableObject {
    @Published var coin: CoinGeckoCoin
    @Published var historicalData: [Double] = [] // Stores the price data for the chart
    @Published var coinOverview: String = "" // Stores the description (overview)
    
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
    
    init(coin: CoinGeckoCoin) {
        self.coin = coin
        fetchHistoricalData(for: coin.id)  // Fetch historical price data
        fetchCoinOverview(for: coin.id)    // Fetch coin description
        
    }
    
    func fetchHistoricalData(for coinId: String) {
        let urlString = "\(apiURL)/coins/\(coinId)/market_chart?vs_currency=usd&days=7"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for historical data.")
            return
        }
        
        print("Fetching historical data from URL: \(urlString)")  // Add debugging output
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]
        
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: CoinMarketChart.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Successfully fetched historical data.")
                case .failure(let error):
                    print("Error fetching historical data: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] chartData in
                self?.historicalData = chartData.prices.map { $0[1] } // Store the prices
                print("Historical data: \(chartData.prices)") // Debugging output to ensure prices are received
            })
    }

    
    
    func fetchCoinOverview(for coinId: String) {
        // Construct the base URL
        var components = URLComponents(string: "\(apiURL)/coins/\(coinId)")!
        
        // Append the API key as a query parameter
        components.queryItems = [
            URLQueryItem(name: "x_cg_demo_api_key", value: apiKey)
        ]
        
        // Ensure the URL is valid
        guard let url = components.url else {
            print("Invalid URL for coin overview.")
            return
        }

        print("Fetching data from URL: \(url)")  // Debugging

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]
        
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: CoinOverview.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Successfully fetched coin overview.")
                case .failure(let error):
                    print("Error fetching coin overview: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] coinOverview in
                self?.coinOverview = coinOverview.description.en.isEmpty ? "Overview not available" : coinOverview.description.en
            })
    }


    
}

struct CoinMarketChart: Decodable {
    let prices: [[Double]] // Array of [timestamp, price]
}

struct CoinOverview: Decodable {
    let description: Description
    
    struct Description: Decodable {
        let en: String // English description
    }
}
