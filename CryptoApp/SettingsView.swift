import SwiftUI

struct SettingsView: View {
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
            .ignoresSafeArea() // Covers the entire screen
            
            VStack(alignment: .leading, spacing: 20) {
                // App icon and About the App section
                VStack(alignment: .leading) {
                    // App Icon
                    Image("app icon") // Replace with your actual app icon image name
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About the App")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("The app provides an efficient method for users to track and invest in cryptocurrencies by offering real-time updates on market trends. It features a portfolio manager for overseeing investments and integrates live data from APIs for up-to-date market insights.")
                            .foregroundColor(.white)
                            .font(.custom("Poppins-Regular", size: 16))
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 30)
                
                // Divider line
                Divider()
                    .background(Color.white.opacity(0.5))
                    .padding(.horizontal, 16)
                
                // About Us Section with Users Icon
                VStack(alignment: .leading) {
                    // Users Icon
                    Image("Users Icon") // Replace with your actual users icon image name
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About Us")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            
                        
                        // Developer information
                        VStack(alignment: .leading, spacing: 12) {
                            // First developer
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Faraaz Rehan Junaidi Mohammed")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Masters in Computer Science")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.white)
                                
                                // LinkedIn link for Faraaz
                                Link(destination: URL(string: "https://www.linkedin.com/in/faraaz-rehan-junaidi-mohammed-797653191")!) {
                                    Text("LinkedIn Profile")
                                        .foregroundColor(.blue)
                                        .font(.custom("Poppins-Regular", size: 12))
                                }
                            }
                            
                            // Second developer
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Andrew Guzman")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Bachelors in Computer Science")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.white)
                                
                                // LinkedIn link for Andrew
                                Link(destination: URL(string: "https://www.linkedin.com/in/andrew-guzman-50a5b516a")!) {
                                    Text("LinkedIn Profile")
                                        .foregroundColor(.blue)
                                        .font(.custom("Poppins-Regular", size: 12))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
                
                Spacer() // Pushes the content to the top
            }
        }
        .tabItem {
            Image(systemName: "gear")
            Text("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
