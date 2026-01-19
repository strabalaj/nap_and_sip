import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var babyViewModel: BabyViewModel
    @StateObject private var viewModel = TimelineViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.events.isEmpty {
                    emptyState
                } else {
                    eventsList
                }
            }
            .navigationTitle("Timeline")
            .task {
                if let babyId = babyViewModel.selectedBaby?.id {
                    viewModel.observeEvents(for: babyId)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Constants.Spacing.md) {
            Image(systemName: "calendar")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("No events yet")
                .font(.headline)

            Text("Start logging your baby's activities")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var eventsList: some View {
        List {
            ForEach(viewModel.groupedEvents, id: \.0) { dateString, events in
                Section(header: Text(dateString)) {
                    ForEach(events, id: \.id) { event in
                        EventCard(event: event)
                    }
                    .onDelete { indexSet in
                        Task {
                            for index in indexSet {
                                await viewModel.deleteEvent(events[index])
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    TimelineView()
        .environmentObject(BabyViewModel())
}
