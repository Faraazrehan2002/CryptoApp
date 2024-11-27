import Foundation

struct NewsResponse: Codable {
    let Data: [NewsArticle]
}

struct NewsArticle: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let url: String
    let source: String
    let imageurl: String?
}


