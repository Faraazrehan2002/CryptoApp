import SwiftUI
import Charts

struct CryptoDetailView: View {
    let viewModel: CryptoDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var isFullScreenChartPresented = false
    @State private var isFullOverviewPresented = false
    @State private var isTruncated: Bool = false

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#851439"), Color(hex: "#151E52")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                // Navigation Back Button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                            Text("Back")
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                    // Coin Symbol and Icon
                    HStack {
                        Text(viewModel.coin.symbol.uppercased())
                            .font(.custom("Poppins-Bold", size: 24))
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

                // Chart Section
                VStack {
                    Chart {
                        ForEach(Array(viewModel.coin.sparkline_in_7d.price.enumerated()), id: \.offset) { index, value in
                            let leftMostValue = viewModel.coin.sparkline_in_7d.price.first ?? 0
                            let rightMostValue = viewModel.coin.sparkline_in_7d.price.last ?? 0
                            let color = rightMostValue >= leftMostValue ? Color.green : Color.red

                            LineMark(
                                x: .value("Time", index),
                                y: .value("Price", value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(color)
                            .lineStyle(StrokeStyle(lineWidth: 2))

                            AreaMark(
                                x: .value("Time", index),
                                yStart: .value("Price", yAxisRange.lowerBound),
                                yEnd: .value("Price", value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.2), color.opacity(0.0)]),
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                        }
                    }
                    .chartXScale(domain: xAxisRange)
                    .chartYScale(domain: yAxisRange)
                    .chartXAxis {
                        AxisMarks(preset: .aligned) {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    .chartYAxis {
                        AxisMarks(preset: .aligned) {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(Color.gray.opacity(0.5))
                            AxisTick()
                            AxisValueLabel(format: .currency(code: "USD"))
                        }
                    }
                    .chartPlotStyle { plotArea in
                        plotArea
                            .background(Color(hex: "#0E2433"))
                            .border(Color.gray.opacity(0.2), width: 1)
                    }
                    .frame(height: 250 * scale)
                    .frame(maxWidth: .infinity, alignment: .center) // Center the chart
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = min(max(1.0, value), 3.0)
                            }
                    )
                    .onTapGesture {
                        isFullScreenChartPresented.toggle()
                    }
                    .padding(.horizontal)
                }

                // Overview Section
                Text("Overview")
                    .font(.custom("Poppins-Bold", size: 20))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .bold()

                VStack(alignment: .leading) {
                    // Limited to 4 lines
                    Text(viewModel.coinOverview)
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.white)
                        .lineLimit(isTruncated ? nil : 4) // Limit to 4 lines initially

                    // Show "Read more..." button if text exceeds 4 lines
                    if !isTruncated && viewModel.coinOverview.count > 200 { // Assume truncation if text is long
                        Button(action: {
                            isFullOverviewPresented.toggle()
                        }) {
                            Text("Read more...")
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)

                // Arrange the stats into two rows: Current Price & Market Cap, then Rank & Volume
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .top) {
                        StatRow(
                            title: "Current Price",
                            value: "$\(String(format: "%.2f", viewModel.coin.current_price))",
                            change: viewModel.coin.price_change_percentage_24h
                        )
                        .frame(width: 150, alignment: .leading) // Fixed width for the first StatRow

                        StatRow(
                            title: "Market Cap",
                            value: "$\(String(format: "%.2fBn", viewModel.coin.market_cap / 1_000_000_000))",
                            change: viewModel.coin.marketCapChangePercentage24h
                        )
                        .frame(width: 150, alignment: .leading) // Same fixed width for the second StatRow
                        Spacer()
                    }

                    HStack(alignment: .top) {
                        StatRow(title: "Rank", value: "\(viewModel.coin.rank)")
                            .frame(width: 150, alignment: .leading) // Same fixed width for first StatRow

                        StatRow(
                            title: "Volume",
                            value: "$\(String(format: "%.2fBn", viewModel.coin.total_volume / 1_000_000_000))"
                        )
                        .frame(width: 150, alignment: .leading) // Same fixed width for second StatRow
                        Spacer()
                    }


                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isFullOverviewPresented) {
            FullOverviewView(overview: viewModel.coinOverview)
        }
        .sheet(isPresented: $isFullScreenChartPresented) {
            FullScreenChartView(sparkline: viewModel.coin.sparkline_in_7d.price)
        }
    }

    // Calculate Y-axis range based on the data
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




struct FullOverviewView: View {
    let overview: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Gradient Background (Matching the app's background)
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#851439"), Color(hex: "#151E52")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                // Close Button and Heading
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                        Text("Close")
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding([.leading, .top])

                Text("Overview")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading)
                    .bold()

                // Scrollable Overview Text with Hyperlinks Support
                ScrollView {
                    Text(parseHyperlinks(from: overview))
                        .padding()
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // Function to parse hyperlinks and return a properly formatted AttributedString
    private func parseHyperlinks(from rawText: String) -> AttributedString {
        var attributedString = AttributedString(rawText)

        // Regular expression to find all <a href="...">...</a> tags
        let regex = try! NSRegularExpression(pattern: "<a href=\"(.*?)\">(.*?)</a>", options: [])

        // Extract matches for all hyperlinks
        let matches = regex.matches(in: rawText, options: [], range: NSRange(rawText.startIndex..., in: rawText))

        for match in matches.reversed() {
            guard let linkRange = Range(match.range(at: 1), in: rawText), // URL inside href=""
                  let textRange = Range(match.range(at: 2), in: rawText) // Displayed text inside <a>...</a>
            else { continue }

            let linkURL = rawText[linkRange]
            let displayText = rawText[textRange]

            // Create a clickable AttributedString for the display text
            var linkAttributedString = AttributedString(displayText)
            var linkAttributes = AttributeContainer()
            linkAttributes.link = URL(string: String(linkURL)) // Add URL as link
            linkAttributes.foregroundColor = .blue // Highlight clickable links with blue color

            // Apply link attributes
            linkAttributedString.mergeAttributes(linkAttributes)

            // Convert NSRange to Range<String.Index> in the original string
            if let matchRange = Range(match.range, in: rawText) {
                let fullMatchString = rawText[matchRange]

                // Replace the entire <a href="...">...</a> with the clickable attributed string
                if let rangeInAttributedString = attributedString.range(of: String(fullMatchString)) {
                    attributedString.replaceSubrange(rangeInAttributedString, with: linkAttributedString)
                }
            }
        }

        return attributedString
    }

}


// Full-Screen Chart View


struct FullScreenChartView: View {
    let sparkline: [Double]

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // Dismiss full screen chart
                    }) {
                        Text("Close")
                            .foregroundColor(.white)
                            .padding()
                    }
                }

                Chart {
                    ForEach(Array(sparkline.enumerated()), id: \.offset) { index, value in
                        let previousValue = index > 0 ? sparkline[index - 1] : value
                        let color = value > previousValue ? Color.green : Color.red

                        LineMark(
                            x: .value("Day", index),
                            y: .value("Price", value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(color) // Increase/Decrease line color
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .aligned) {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.5)) // White grid lines in full screen
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(.clear)
                        .border(Color.white.opacity(0.2), width: 1)
                }
                .frame(height: 400)
            }
        }
    }
}

// Helper View to Display Stats
struct StatRow: View {
    var title: String
    var value: String
    var change: Double? // The percentage change (optional)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .regular)) // Use system regular or custom
            Text(value)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold)) // Force system bold
            if let change = change {
                Text(String(format: "%.2f%%", change))
                    .foregroundColor(change < 0 ? .red : .green)
                    .font(.system(size: 14)) // Regular font for percentage change
            }
        }
    }
}
