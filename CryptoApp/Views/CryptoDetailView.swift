import SwiftUI
import Charts

struct CryptoDetailView: View {
    let viewModel: CryptoDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var isFullOverviewPresented = false
    @State private var isLandscape: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#851439"), Color(hex: "#151E52")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if isLandscape {
                    // Landscape Layout
                    ScrollView {
                        VStack(spacing: 8) { // Reduced vertical spacing
                            header
                                .padding(.bottom, 8)
                            
                            overview // Overview is vertically stacked below chart and stats
                                .padding(.bottom, 3)

                            HStack(alignment: .center, spacing: 12) { // Adjusted spacing between chart and stats
                                chart
                                    .frame(maxWidth: geometry.size.width * 0.5) // Chart takes 50% of width
                                stats
                                    .frame(maxWidth: geometry.size.width * 0.5) // Stats take the remaining 50%
                            }

                            
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: geometry.size.height - geometry.safeAreaInsets.bottom - 17)
                    //.padding(.bottom, geometry.safeAreaInsets.bottom + 1)
                } else {
                    // Portrait Layout
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) { // Reduced vertical spacing
                            header
                                .padding(.bottom, 8)

                            chart
                                .padding(.bottom, 8)

                            overview
                                .padding(.bottom, 8)

                            stats
                        }
                        .padding(.horizontal)
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
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isFullOverviewPresented) {
            FullOverviewView(overview: viewModel.coinOverview)
        }
    }

    private func updateOrientation() {
        isLandscape = UIDevice.current.orientation.isLandscape
    }

    private var header: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                    Text("Back")
                        .font(Font.custom("Poppins-Bold", size: 24))
                        .foregroundColor(.white)
                }
            }
            Spacer()
            HStack {
                Text(viewModel.coin.symbol.uppercased())
                    .font(Font.custom("Poppins-Bold", size: 24))
                    .foregroundColor(.white)
                AsyncImage(url: URL(string: viewModel.coin.image)) { image in
                    image
                        .resizable()
                        .frame(width: 30, height: 30)
                } placeholder: {
                    ProgressView()
                        .frame(width: 30, height: 30)
                }
            }
        }
        .padding(.horizontal)
    }

    private var chart: some View {
        VStack {
            Chart {
                ForEach(Array(viewModel.coin.sparkline_in_7d.price.enumerated()), id: \.offset) { index, value in
                    let color: Color = (viewModel.coin.price_change_percentage_24h >= 0) ? .green : .red
                    LineMark(
                        x: .value("Time", index),
                        y: .value("Price", value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(color)
                }
            }
            .chartXScale(domain: xAxisRange)
            .chartYScale(domain: yAxisRange)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color(hex: "#0E2433"))
                    .border(Color.gray.opacity(0.2), width: 1)
            }
            .frame(height: 250)
        }
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(Font.custom("Poppins-Bold", size: 20))
                .foregroundColor(.white)
            Text(viewModel.coinOverview)
                .font(Font.custom("Poppins-Medium", size: 16))
                .foregroundColor(.white)
                .lineLimit(isLandscape ? 3 : 4) // 3 lines in landscape, 4 in portrait
                .multilineTextAlignment(.leading)
            Button(action: { isFullOverviewPresented.toggle() }) {
                Text("Read more...")
                    .font(Font.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }

    private var stats: some View {
        VStack(alignment: .leading, spacing: 12) { // Reduced spacing between stats rows
            HStack(spacing: 16) { // Adjusted spacing between stats columns
                StatRow(
                    title: "Current Price",
                    value: "$\(String(format: "%.2f", viewModel.coin.current_price))",
                    change: viewModel.coin.price_change_percentage_24h
                )
                Spacer()
                StatRow(
                    title: "Market Cap",
                    value: "$\(String(format: "%.2fBn", viewModel.coin.market_cap / 1_000_000_000))",
                    change: viewModel.coin.marketCapChangePercentage24h
                )
            }
            HStack(spacing: 16) {
                StatRow(
                    title: "Rank",
                    value: "\(viewModel.coin.rank)",
                    change: nil
                )
                Spacer()
                StatRow(
                    title: "Volume",
                    value: "$\(String(format: "%.2fBn", viewModel.coin.total_volume / 1_000_000_000))",
                    change: nil
                )
               .padding(.horizontal, 40)
            }
        }
    }

    var yAxisRange: ClosedRange<Double> {
        let minValue = viewModel.coin.sparkline_in_7d.price.min() ?? 0
        let maxValue = viewModel.coin.sparkline_in_7d.price.max() ?? 1
        let buffer = (maxValue - minValue) * 0.1
        return (minValue - buffer)...(maxValue + buffer)
    }

    var xAxisRange: ClosedRange<Int> {
        let count = viewModel.coin.sparkline_in_7d.price.count
        return 0...(count - 1)
    }
}



// MARK: - FullOverviewView

struct FullOverviewView: View {
    let overview: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#851439"), Color(hex: "#151E52")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // Close Button
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                            Text("Close")
                                .font(Font.custom("Poppins-Medium", size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .padding()

                // Centered Title
                Text("Overview")
                    .font(Font.custom("Poppins-Bold", size: 32))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 16)

                // Content with Links
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        if let attributedText = parseHTMLToAttributedString(from: overview) {
                            Text(attributedText)
                                .font(Font.custom("Poppins-Medium", size: 26))
                                .lineSpacing(6) // Adjust line spacing
                                .padding()
                        } else {
                            Text("Error parsing content.")
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                }
            }
        }
    }

    // Function to parse HTML and apply font size and custom link color
    private func parseHTMLToAttributedString(from html: String) -> AttributedString? {
        guard let data = html.data(using: .utf8) else { return nil }

        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]

            let nsAttributedString = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)

            // Apply explicit font and color styles
            nsAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: nsAttributedString.length)) // Font size
            nsAttributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: nsAttributedString.length)) // Default text color

            // Apply custom blue color for links
            let customBlue = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0) // Brighter, contrasting blue
            nsAttributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: nsAttributedString.length), options: []) { value, range, _ in
                if value != nil {
                    nsAttributedString.addAttribute(.foregroundColor, value: customBlue, range: range) // Link color
                }
            }

            return AttributedString(nsAttributedString)
        } catch {
            print("Error parsing HTML: \(error)")
            return nil
        }
    }
}


// Struct for parsed content
private struct ParsedContent: Identifiable {
    let id = UUID()
    let text: String
    let isLink: Bool
    let url: URL?

    init(text: String, isLink: Bool, url: URL? = nil) {
        self.text = text
        self.isLink = isLink
        self.url = url
    }
}

private extension NSRange {
    func lowerBound(in string: String) -> String.Index {
        return String.Index(utf16Offset: self.lowerBound, in: string)
    }
}







struct StatRow: View {
    let title: String
    let value: String
    let change: Double?

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(Font.custom("Poppins-Bold", size: 20))
                .foregroundColor(.white)
            Text(value)
                .font(Font.custom("Poppins-Medium", size: 16))
                .foregroundColor(.white)
                .bold()
            if let change = change {
                Text("\(String(format: "%.2f", change))%")
                    .font(Font.custom("Poppins-Medium", size: 14))
                    .foregroundColor(change < 0 ? .red : .green)
                    .font(.footnote)
            }
        }
    }
}

struct FullScreenChartView: View {
    let sparkline: [Double]

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button(action: { }) {
                        Text("Close")
                            .font(Font.custom("Poppins-Medium", size: 24))
                            .foregroundColor(.white)
                            .padding()
                    }
                }

                Chart {
                    ForEach(Array(sparkline.enumerated()), id: \.offset) { index, value in
                        LineMark(
                            x: .value("Day", index),
                            y: .value("Price", value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(value > (index > 0 ? sparkline[index - 1] : value) ? .green : .red)
                    }
                }
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(Color.black.opacity(0.3))
                }
                .frame(height: 400)
            }
        }
    }
}
