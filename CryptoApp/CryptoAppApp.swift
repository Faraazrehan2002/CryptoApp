//
//  CryptoAppApp.swift
//  CryptoApp
//
//  Created by Faraaz Rehan Junaidi Mohammed on 9/29/24.
//

import SwiftUI

@main
struct CryptoAppApp: App {
    init() {
        setupTabBarAppearance()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Set a semi-transparent, dark blue tab bar background to blend with your gradient
        appearance.backgroundColor = UIColor(white: 0.05, alpha: 0.25) // Darker transparent blue-ish color
        
        // Unselected state: A lighter white (visible but not too bright)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 1.0, alpha: 0.4) // Light white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(white: 1.0, alpha: 0.4)]
        
        // Selected state: A brighter white to stand out
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(white: 1.0, alpha: 1.0) // Bright white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(white: 1.0, alpha: 1.0)]

        // Apply this to the tab bar appearance
        UITabBar.appearance().standardAppearance = appearance

        // Apply for iOS 15+ for scrollEdgeAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}


extension Color {
    // Custom initializer to allow hex color usage
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

