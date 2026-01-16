import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var babyViewModel: BabyViewModel

    @State private var selectedTimeRange: TimeRange = .week

    enum TimeRange: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Spacing.lg) {
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    sleepSummaryCard

                    feedingSummaryCard

                    diaperSummaryCard
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
        }
    }

    private var sleepSummaryCard: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Image(systemName: Constants.Icons.sleep)
                    .foregroundColor(.sleepColor)
                Text("Sleep")
                    .font(.headline)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Avg. Daily")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("-- hrs")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Naps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("--")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .cardStyle()
        .padding(.horizontal)
    }

    private var feedingSummaryCard: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Image(systemName: Constants.Icons.feed)
                    .foregroundColor(.feedColor)
                Text("Feeding")
                    .font(.headline)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Avg. Daily")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("-- oz")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Feedings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("--")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .cardStyle()
        .padding(.horizontal)
    }

    private var diaperSummaryCard: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Image(systemName: Constants.Icons.diaper)
                    .foregroundColor(.diaperColor)
                Text("Diapers")
                    .font(.headline)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("--")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Avg. Daily")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("--")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .cardStyle()
        .padding(.horizontal)
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(BabyViewModel())
}
