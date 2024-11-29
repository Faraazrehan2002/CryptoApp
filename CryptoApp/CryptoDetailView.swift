import SwiftUI
import Charts

struct CryptoDetailView: View {
    let viewModel: CryptoDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var isFullScreenChartPresented = false
    @State private var isFullOverviewPresented = false
    @State private var isLandscape: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#851439"), Color(hex: "#151E52")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if isLandscape {
                    ScrollView {
                        VStack(spacing: 16) {
                            header
                            chart
                            stats
                            overview
                        }
                        .padding(.horizontal)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        chart
                        overview
                        stats
                        Spacer()
                    }
                    .padding(.horizontal)
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
        .sheet(isPresented: $isFullScreenChartPresented) {
            FullScreenChartView(sparkline: viewModel.coin.sparkline_in_7d.price)
        }
    }

    private func updateOrientation() {
        isLandscape = UIDevice.current.orientation.isLandscape
    }

    // MARK: - Header Section
    private var header: some View {
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
    }

    // MARK: - Chart Section with Background and No Labels
    private var chart: some View {
        VStack {
            Chart {
                ForEach(Array(viewModel.coin.sparkline_in_7d.price.enumerated()), id: \.offset) { index, value in
                    let color: Color = (viewModel.coin.sparkline_in_7d.price.last ?? 0) >= (viewModel.coin.sparkline_in_7d.price.first ?? 0) ? .green : .red
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
            .chartXAxis {
                AxisMarks { _ in }
            }
            .chartYAxis { 
                AxisMarks { _ in }
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color(hex: "#0E2433"))
                    .border(Color.gray.opacity(0.2), width: 1)
            }
            .frame(height: 250 * scale)
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
    }

    // MARK: - Overview Section
    private var overview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(.white)
            Text(viewModel.coinOverview)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.white)
                .lineLimit(isLandscape ? nil : 4)
            if !isLandscape && viewModel.coinOverview.count > 200 {
                Button(action: { isFullOverviewPresented.toggle() }) {
                    Text("Read more...")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.blue)
                }
            }
        }
    }

    // MARK: - Stats Section
    private var stats: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                StatRow(
                    title: "Current Price",
                    value: "$\(String(format: "%.2f", viewModel.coin.current_price))",
                    change: viewModel.coin.price_change_percentage_24h
                )
                .padding()
                Spacer()
                StatRow(
                    title: "Market Cap",
                    value: "$\(String(format: "%.2fBn", viewModel.coin.market_cap / 1_000_000_000))",
                    change: viewModel.coin.marketCapChangePercentage24h
                )
            }
            HStack(spacing: 20) {
                StatRow(
                    title: "Rank",
                    value: "\(viewModel.coin.rank)",
                    change: nil
                )
                .padding()
                Spacer()
                StatRow(
                    title: "Volume",
                    value: "$\(String(format: "%.2fBn", viewModel.coin.total_volume / 1_000_000_000))",
                    change: nil
                )
                .padding(.horizontal, 15)
            }
        }
    }

    // MARK: - Axis Ranges
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
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#851439"), Color(hex: "#151E52")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                            Text("Close")
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .padding()

                Text("Overview")
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()

                ScrollView {
                    Text(overview)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .padding(.top)
        }
    }
}

// MARK: - StatRow Component
struct StatRow: View {
    let title: String
    let value: String
    let change: Double?

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
            Text(value)
                .foregroundColor(.white)
                .font(.title3)
                .bold()
            if let change = change {
                Text("\(String(format: "%.2f", change))%")
                    .foregroundColor(change < 0 ? .red : .green)
                    .font(.footnote)
            }
        }
    }
}

// MARK: - FullScreenChartView
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
