import SwiftUI
import SwiftUI
import Charts

struct SleepChartView: View {
    let data: [DaySummary]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sleep Overview")
                .font(.headline)

            Chart(data) { day in
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Hours", day.totalSleepHours)
                )
                .foregroundStyle(Color.purple.gradient)
                .cornerRadius(4)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let hours = value.as(Double.self) {
                            Text("\(Int(hours))h")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

struct FeedingChartView: View {
    let data: [DaySummary]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Feeding Overview")
                .font(.headline)

            Chart(data) { day in
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Oz", day.totalVolume)
                )
                .foregroundStyle(Color.pink.gradient)
                .cornerRadius(4)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let oz = value.as(Double.self) {
                            Text("\(Int(oz))oz")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

struct WakeWindowChartView: View {
    let wakeWindows: [WakeWindow]
    let optimalRange: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Wake Windows")
                    .font(.headline)
                Spacer()
                Text("Optimal: \(Int(optimalRange.lowerBound/60))-\(Int(optimalRange.upperBound/60)) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Chart {
                RectangleMark(
                    xStart: .value("Start", optimalRange.lowerBound / 60),
                    xEnd: .value("End", optimalRange.upperBound / 60),
                    yStart: nil,
                    yEnd: nil
                )
                .foregroundStyle(Color.green.opacity(0.2))

                ForEach(Array(wakeWindows.enumerated()), id: \.element.id) { index, window in
                    PointMark(
                        x: .value("Duration", window.duration / 60),
                        y: .value("Window", "Nap \(index + 1)")
                    )
                    .foregroundStyle(windowColor(for: window))
                    .symbolSize(100)
                }
            }
            .chartXAxisLabel("Minutes")
            .frame(height: 150)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private func windowColor(for window: WakeWindow) -> Color {
        switch window.quality {
        case .short: return .orange
        case .optimal: return .green
        case .long: return .yellow
        case .tooLong: return .red
        case .none: return .gray
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color

    init(title: String, value: String, subtitle: String? = nil, icon: String, color: Color = .blue) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            SleepChartView(data: DaySummary.sampleWeek)
            FeedingChartView(data: DaySummary.sampleWeek)

            HStack(spacing: 12) {
                StatCard(
                    title: "Avg Sleep",
                    value: "14.2h",
                    subtitle: "per day",
                    icon: "moon.fill",
                    color: .purple
                )
                StatCard(
                    title: "Avg Feeds",
                    value: "28oz",
                    subtitle: "per day",
                    icon: "drop.fill",
                    color: .pink
                )
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
