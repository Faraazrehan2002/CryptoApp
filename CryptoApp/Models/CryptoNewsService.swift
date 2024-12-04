import Foundation

class CryptoNewsService: ObservableObject {
    @Published var newsArticles: [NewsArticle] = []
    
    func fetchNews() {
        guard let url = URL(string: "https://min-api.cryptocompare.com/data/v2/news/?lang=EN&api_key=c764421374b520190d1b5d2690241ac8dae63d1cadc12d487a2158bdce3363cf") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching news: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                // Print the raw JSON response
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("Raw JSON response: \(json)")
                }
                
                let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.newsArticles = newsResponse.Data 
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}
