import SwiftUI

struct CryptoNewsView: View {
    @StateObject private var newsService = CryptoNewsService()

    var body: some View {
        NavigationView {
            ZStack {
                // Full-page Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#851439"),
                        Color(hex: "#151E52")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea() // Makes the gradient cover the entire screen
                
                VStack(spacing: 0) {
                    // Header Title
                    Text("Crypto News")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.clear)
                    
                    // News List
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
                                .foregroundColor(.white)
                            Text(article.body)
                                .font(.body)
                                .lineLimit(3)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Link("Read more", destination: URL(string: article.url)!)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "#851439"),
                                            Color(hex: "#151E52")
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .listRowBackground(Color.clear) // Transparent row background
                    }
                    .listStyle(PlainListStyle()) // Removes extra list padding
                    .background(Color.clear) // Makes the list's background transparent
                }
                .padding(.bottom, 50) // Ensures content does not extend into the tab bar
            }
            .navigationBarHidden(true) // Hides default navigation bar
            .onAppear {
                newsService.fetchNews()
            }
        }
    }
}

#Preview {
    CryptoNewsView()
}
