import SwiftUI

struct EventDetailView: View {
    let event: any BabyEvent
    @EnvironmentObject var babyViewModel: BabyViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: event.type.icon)
                        .font(.title2)
                        .foregroundColor(event.type.color)
                        .frame(width: 44, height: 44)
                        .background(event.type.color.opacity(0.15))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.type.displayName)
                            .font(.headline)
                        Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section("Details") {
                eventSpecificDetails
            }

            if let notes = event.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                }
            }

            Section {
                HStack {
                    Text("Logged by")
                    Spacer()
                    Text("You")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Created")
                    Spacer()
                    Text(event.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(.secondary)
                }
                if event.updatedAt != event.createdAt {
                    HStack {
                        Text("Last updated")
                        Spacer()
                        Text(event.updatedAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section {
                Button("Edit Event") {
                    showingEditSheet = true
                }

                Button("Delete Event", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EventEditView(event: event)
        }
        .confirmationDialog("Delete Event", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteEvent()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this event? This action cannot be undone.")
        }
    }

    @ViewBuilder
    private var eventSpecificDetails: some View {
        if let feedEvent = event as? FeedEvent {
            feedDetails(feedEvent)
        } else if let sleepEvent = event as? SleepEvent {
            sleepDetails(sleepEvent)
        } else if let diaperEvent = event as? DiaperEvent {
            diaperDetails(diaperEvent)
        } else if let milestoneEvent = event as? MilestoneEvent {
            milestoneDetails(milestoneEvent)
        }
    }

    @ViewBuilder
    private func feedDetails(_ feed: FeedEvent) -> some View {
        HStack {
            Text("Method")
            Spacer()
            Text(feed.method.displayName)
                .foregroundColor(.secondary)
        }

        if let volume = feed.volume {
            HStack {
                Text("Volume")
                Spacer()
                Text("\(volume, specifier: "%.1f") oz")
                    .foregroundColor(.secondary)
            }
        }

        if let side = feed.side {
            HStack {
                Text("Side")
                Spacer()
                Text(side.displayName)
                    .foregroundColor(.secondary)
            }
        }

        if let duration = feed.duration {
            HStack {
                Text("Duration")
                Spacer()
                Text("\(duration) min")
                    .foregroundColor(.secondary)
            }
        }

        if let foodType = feed.foodType {
            HStack {
                Text("Food")
                Spacer()
                Text(foodType)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private func sleepDetails(_ sleep: SleepEvent) -> some View {
        HStack {
            Text("Type")
            Spacer()
            Text(sleep.isNightSleep ? "Night Sleep" : "Nap")
                .foregroundColor(.secondary)
        }

        HStack {
            Text("Started")
            Spacer()
            Text(sleep.startTime.formatted(date: .omitted, time: .shortened))
                .foregroundColor(.secondary)
        }

        if let endTime = sleep.endTime {
            HStack {
                Text("Ended")
                Spacer()
                Text(endTime.formatted(date: .omitted, time: .shortened))
                    .foregroundColor(.secondary)
            }

            if let duration = sleep.duration {
                HStack {
                    Text("Duration")
                    Spacer()
                    Text(sleep.durationFormatted ?? "")
                        .foregroundColor(.secondary)
                }
            }
        } else {
            HStack {
                Text("Status")
                Spacer()
                Text("In progress")
                    .foregroundColor(.orange)
            }
        }

        if let quality = sleep.quality {
            HStack {
                Text("Quality")
                Spacer()
                Text(quality.displayName)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private func diaperDetails(_ diaper: DiaperEvent) -> some View {
        HStack {
            Text("Type")
            Spacer()
            Label(diaper.diaperType.displayName, systemImage: diaper.diaperType.icon)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func milestoneDetails(_ milestone: MilestoneEvent) -> some View {
        HStack {
            Text("Milestone")
            Spacer()
            Text(milestone.title)
                .foregroundColor(.secondary)
        }

        HStack {
            Text("Category")
            Spacer()
            Label(milestone.category.rawValue, systemImage: milestone.category.icon)
                .foregroundColor(.secondary)
        }

        if let description = milestone.milestoneDescription {
            VStack(alignment: .leading, spacing: 4) {
                Text("Description")
                Text(description)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func deleteEvent() {
        guard let babyId = babyViewModel.selectedBaby?.id else { return }

        Task {
            do {
                try await EventService.shared.deleteEvent(event, for: babyId)
                dismiss()
            } catch {
                Logger.error("Failed to delete event", error: error, category: Logger.events)
            }
        }
    }
}
