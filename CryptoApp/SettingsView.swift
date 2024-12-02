import SwiftUI

struct SettingsView: View {
    @State private var isLandscape: Bool = false

    var body: some View {
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

            VStack {
                // Headline
                Text("Settings")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if isLandscape {
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
                            .padding(.top, 30)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear {
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
        .tabItem {
            Image(systemName: "gear")
            Text("Settings")
        }
    }

    private func updateOrientation() {
        isLandscape = UIDevice.current.orientation.isLandscape
    }

    // App Details Section
    private var appDetails: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image("app icon")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 8) {
                Text("About the App")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)

                Text("""
                The app provides an efficient method for users to track and invest in cryptocurrencies by offering real-time updates on market trends. It features a portfolio manager for overseeing investments and integrates live data from APIs for up-to-date market insights.
                """)
                    .foregroundColor(.white)
                    .font(.custom("Poppins-Regular", size: 16))
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
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Faraaz Rehan Junaidi Mohammed")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("Masters in Computer Science")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.white)

                        Link(destination: URL(string: "https://www.linkedin.com/in/faraaz-rehan-junaidi-mohammed-797653191")!) {
                            Text("LinkedIn Profile")
                                .foregroundColor(.blue)
                                .font(.custom("Poppins-Regular", size: 12))
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Andrew Guzman")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("Bachelors in Computer Science")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.white)

                        Link(destination: URL(string: "https://www.linkedin.com/in/andrew-guzman-50a5b516a")!) {
                            Text("LinkedIn Profile")
                                .foregroundColor(.blue)
                                .font(.custom("Poppins-Regular", size: 12))
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
