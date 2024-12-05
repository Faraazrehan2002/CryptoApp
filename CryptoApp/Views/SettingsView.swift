import SwiftUI

struct SettingsView: View {
    @State private var isLandscape: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#851439"), // Magenta-like color
                        Color(hex: "#151E52")  // Dark blue color
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Headline
                    Text("About")
                        .font(Font.custom("Poppins-Bold", size: 32))
                        .foregroundColor(.white)
                        .padding(.top, 5)

                    // Content in ScrollView
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            if isLandscape {
                                // Landscape Layout
                                HStack(alignment: .top, spacing: 20) {
                                    appDetails
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    aboutUs
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal)
                            } else {
                                // Portrait Layout
                                VStack(alignment: .leading, spacing: 20) {
                                    appDetails
                                    aboutUs
                                }
                                .padding(.horizontal)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 30) // Padding for tab bar
                    }
                    .frame(height: geometry.size.height - geometry.safeAreaInsets.bottom - 30) // Adjust ScrollView height
                }
            }
            .onAppear {
                updateOrientation(with: geometry.size)
                NotificationCenter.default.addObserver(
                    forName: UIDevice.orientationDidChangeNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    updateOrientation(with: geometry.size)
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
        .tabItem {
            Image(systemName: "person.circle")
            Text("About")
        }
    }

    private func updateOrientation(with size: CGSize) {
        isLandscape = size.width > size.height
    }

    // App Details Section
    private var appDetails: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image("Settings Icon")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 8) {
                Text("About the App")
                    .font(Font.custom("Poppins-Bold", size: 24))
                    .foregroundColor(.white)

                Text("""
                The app provides an efficient method for users to track and invest in cryptocurrencies by offering real-time updates on market trends. It features a portfolio manager for overseeing investments and integrates live data from APIs for up-to-date market insights.
                """)
                    .foregroundColor(.white)
                    .font(.custom("Poppins-Medium", size: 16))
                    .lineSpacing(4)
            }
        }
    }

    // About Us Section
    private var aboutUs: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image("Users Icon")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 8) {
                Text("About Us")
                    .font(Font.custom("Poppins-Bold", size: 24))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Faraaz Rehan Junaidi Mohammed")
                            .font(Font.custom("Poppins-Bold", size: 16))
                            .foregroundColor(.white)
                        Text("Masters in Computer Science")
                            .font(Font.custom("Poppins-Medium", size: 16))
                            .foregroundColor(.white)

                        Link(destination: URL(string: "https://www.linkedin.com/in/faraaz-rehan-junaidi-mohammed-797653191")!) {
                            Text("LinkedIn Profile")
                                .foregroundColor(.blue)
                                .font(Font.custom("Poppins-Medium", size: 12))
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Andrew Guzman")
                            .font(Font.custom("Poppins-Bold", size: 18))
                            .foregroundColor(.white)
                        Text("Bachelors in Computer Science")
                            .font(Font.custom("Poppins-Medium", size: 16))
                            .foregroundColor(.white)

                        Link(destination: URL(string: "https://www.linkedin.com/in/andrew-guzman-50a5b516a")!) {
                            Text("LinkedIn Profile")
                                .foregroundColor(.blue)
                                .font(Font.custom("Poppins-Medium", size: 12))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
