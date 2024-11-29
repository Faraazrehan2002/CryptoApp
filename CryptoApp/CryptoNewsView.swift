import SwiftUI

struct CryptoNewsView: View {
    @StateObject private var newsService = CryptoNewsService()
        @State private var isLandscape: Bool = false 

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

                    if isLandscape {
                        // Landscape Layout
                        HStack {
                            List(newsService.newsArticles) { article in
                                VStack(alignment: .leading, spacing: 10) {
                                    if let imageUrl = article.imageurl, let url = URL(string: imageUrl) {
                                        AsyncImage(url: url)
                                            .frame(maxWidth: .infinity, maxHeight: 150)
                                            .aspectRatio(contentMode: .fill)
                                            .clipped()
                                    }
                                    Text(article.title)
                                        .font(.headline)
                                    Text(article.body)
                                        .font(.body)
                                        .lineLimit(3)
                                        .foregroundColor(.secondary)
                                    
                                    Link("Read more", destination: URL(string: article.url)!)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.1))
                                )
                            }
                            .listStyle(PlainListStyle())
                        }
                    } else {
                        // Portrait Layout
                        List(newsService.newsArticles) { article in
                            VStack(alignment: .leading, spacing: 10) {
                                if let imageUrl = article.imageurl, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url)
                                        .frame(maxWidth: .infinity, maxHeight: 200)
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                }
                                Text(article.title)
                                    .font(.headline)
                                Text(article.body)
                                    .font(.body)
                                    .lineLimit(3)
                                    .foregroundColor(.secondary)
                                
                                Link("Read more", destination: URL(string: article.url)!)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("Crypto News")
                .onAppear {
                    newsService.fetchNews()
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
            }
        }

        private func updateOrientation() {
            isLandscape = UIDevice.current.orientation.isLandscape
        }
    }

#Preview {
    CryptoNewsView()
}
