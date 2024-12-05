import SwiftUI

struct CryptoNewsView: View {
    @StateObject private var newsService = CryptoNewsService()
    @State private var isLandscape: Bool = false // Tracks the orientation

    var body: some View {
        GeometryReader { geometry in
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
                    .ignoresSafeArea()

                    VStack(spacing: 0) {
                        // Header Title
                        Text("Crypto News")
                            .font(Font.custom("Poppins-Bold", size: 32))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.clear)

                        if isLandscape {
                            // Landscape Mode: Two columns
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(newsService.newsArticles) { article in
                                        Link(destination: URL(string: article.url)!) {
                                            newsCard(for: article)
                                        }
                                        .buttonStyle(PlainButtonStyle()) // Removes button styling
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: geometry.size.height - geometry.safeAreaInsets.bottom - 50) // Adjusted height
                        } else {
                            // Portrait Mode: Single column
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(newsService.newsArticles) { article in
                                        Link(destination: URL(string: article.url)!) {
                                            newsCard(for: article)
                                        }
                                        .buttonStyle(PlainButtonStyle()) // Removes button styling
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: geometry.size.height - geometry.safeAreaInsets.bottom - 50) // Adjusted height
                        }
                    }
                }
                .navigationBarHidden(true) // Hides default navigation bar
                .onAppear {
                    newsService.fetchNews()
                    updateOrientation(with: geometry.size)
                }
                .onChange(of: geometry.size) { newSize in
                    updateOrientation(with: newSize)
                }
            }
        }
    }

    // MARK: - Helper Views
    private func newsCard(for article: NewsArticle) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let imageUrl = article.imageurl, let url = URL(string: imageUrl) {
                AsyncImage(url: url)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            }
            Text(article.title)
                .font(Font.custom("Poppins-Bold", size: 16))
                .foregroundColor(.white)
            Text(article.body)
                .font(Font.custom("Poppins-Medium", size: 16))
                .lineLimit(3)
                .foregroundColor(.white.opacity(0.7))
            Link("Read more", destination: URL(string: article.url)!)
                .font(Font.custom("Poppins-Medium", size: 16))
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
    }

    // MARK: - Orientation Handling
    private func updateOrientation(with size: CGSize) {
        isLandscape = size.width > size.height
    }
}


#Preview {
    CryptoNewsView()
}
