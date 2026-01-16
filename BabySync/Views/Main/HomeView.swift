import SwiftUI

struct HomeView: View {
    @EnvironmentObject var babyViewModel: BabyViewModel
    @StateObject private var quickLogViewModel = QuickLogViewModel()

    @State private var showFeedSheet = false
    @State private var showSleepSheet = false
    @State private var showDiaperSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Spacing.lg) {
                    if let baby = babyViewModel.selectedBaby {
                        babyHeader(baby)
                    }

                    quickLogButtons

                    recentActivitySection
                }
                .padding()
            }
            .navigationTitle("BabySync")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: Constants.Icons.notification)
                    }
                }
            }
        }
        .sheet(isPresented: $showFeedSheet) {
            FeedLogView()
        }
        .sheet(isPresented: $showSleepSheet) {
            SleepLogView()
        }
        .sheet(isPresented: $showDiaperSheet) {
            DiaperLogView()
        }
    }

    private func babyHeader(_ baby: Baby) -> some View {
        VStack(spacing: Constants.Spacing.sm) {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay {
                    Text(baby.name.prefix(1).uppercased())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }

            Text(baby.name)
                .font(.title2)
                .fontWeight(.semibold)

            Text(baby.ageDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }

    private var quickLogButtons: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Quick Log")
                .font(.headline)

            HStack(spacing: Constants.Spacing.md) {
                QuickLogButton(
                    title: "Feed",
                    icon: Constants.Icons.feed,
                    color: .feedColor
                ) {
                    showFeedSheet = true
                }

                QuickLogButton(
                    title: "Sleep",
                    icon: Constants.Icons.sleep,
                    color: .sleepColor
                ) {
                    showSleepSheet = true
                }

                QuickLogButton(
                    title: "Diaper",
                    icon: Constants.Icons.diaper,
                    color: .diaperColor
                ) {
                    showDiaperSheet = true
                }
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                Spacer()
                NavigationLink("See All") {
                    TimelineView()
                }
                .font(.subheadline)
            }

            Text("No recent activity")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding()
                .cardStyle()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(BabyViewModel())
        .environmentObject(AuthViewModel())
}
