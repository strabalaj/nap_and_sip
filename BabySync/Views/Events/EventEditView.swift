import SwiftUI

struct EventEditView: View {
    let event: any BabyEvent
    @EnvironmentObject var babyViewModel: BabyViewModel
    @Environment(\.dismiss) var dismiss

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var timestamp: Date
    @State private var notes: String

    // Feed-specific
    @State private var feedMethod: FeedEvent.FeedMethod = .bottle
    @State private var feedVolume: Double = 4
    @State private var feedSide: FeedEvent.BreastSide = .left
    @State private var feedDuration: Int = 15
    @State private var feedFoodType: String = ""

    // Sleep-specific
    @State private var sleepStartTime: Date = Date()
    @State private var sleepEndTime: Date = Date()
    @State private var sleepIsNight: Bool = false
    @State private var sleepQuality: SleepEvent.SleepQuality = .good

    // Diaper-specific
    @State private var diaperType: DiaperEvent.DiaperType = .wet

    // Milestone-specific
    @State private var milestoneTitle: String = ""
    @State private var milestoneCategory: MilestoneEvent.MilestoneCategory = .physical
    @State private var milestoneDescription: String = ""

    init(event: any BabyEvent) {
        self.event = event
        _timestamp = State(initialValue: event.timestamp)
        _notes = State(initialValue: event.notes ?? "")

        if let feed = event as? FeedEvent {
            _feedMethod = State(initialValue: feed.method)
            _feedVolume = State(initialValue: feed.volume ?? 4)
            _feedSide = State(initialValue: feed.side ?? .left)
            _feedDuration = State(initialValue: feed.duration ?? 15)
            _feedFoodType = State(initialValue: feed.foodType ?? "")
        } else if let sleep = event as? SleepEvent {
            _sleepStartTime = State(initialValue: sleep.startTime)
            _sleepEndTime = State(initialValue: sleep.endTime ?? Date())
            _sleepIsNight = State(initialValue: sleep.isNightSleep)
            _sleepQuality = State(initialValue: sleep.quality ?? .good)
        } else if let diaper = event as? DiaperEvent {
            _diaperType = State(initialValue: diaper.diaperType)
        } else if let milestone = event as? MilestoneEvent {
            _milestoneTitle = State(initialValue: milestone.title)
            _milestoneCategory = State(initialValue: milestone.category)
            _milestoneDescription = State(initialValue: milestone.milestoneDescription ?? "")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker("Event Time", selection: $timestamp)
                }

                eventSpecificFields

                Section("Notes") {
                    TextField("Add notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit \(event.type.displayName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
        }
    }

    @ViewBuilder
    private var eventSpecificFields: some View {
        switch event.type {
        case .feed:
            feedFields
        case .sleep:
            sleepFields
        case .diaper:
            diaperFields
        case .milestone:
            milestoneFields
        }
    }

    @ViewBuilder
    private var feedFields: some View {
        Section("Feed Details") {
            Picker("Method", selection: $feedMethod) {
                ForEach(FeedEvent.FeedMethod.allCases, id: \.self) { m in
                    Text(m.displayName).tag(m)
                }
            }

            if feedMethod == .bottle || feedMethod == .mixed {
                HStack {
                    Text("Volume")
                    Spacer()
                    Text("\(feedVolume, specifier: "%.1f") oz")
                        .foregroundColor(.secondary)
                }
                Slider(value: $feedVolume, in: 0.5...12, step: 0.5)
            }

            if feedMethod == .breast {
                Picker("Side", selection: $feedSide) {
                    ForEach(FeedEvent.BreastSide.allCases, id: \.self) { s in
                        Text(s.displayName).tag(s)
                    }
                }
                Stepper("Duration: \(feedDuration) min", value: $feedDuration, in: 1...60)
            }

            if feedMethod == .solids {
                TextField("Food Type", text: $feedFoodType)
            }
        }
    }

    @ViewBuilder
    private var sleepFields: some View {
        Section("Sleep Details") {
            Toggle("Night Sleep", isOn: $sleepIsNight)
            DatePicker("Start Time", selection: $sleepStartTime)
            DatePicker("End Time", selection: $sleepEndTime, in: sleepStartTime...)

            Picker("Quality", selection: $sleepQuality) {
                ForEach(SleepEvent.SleepQuality.allCases, id: \.self) { q in
                    Text(q.displayName).tag(q)
                }
            }
        }
    }

    @ViewBuilder
    private var diaperFields: some View {
        Section("Diaper Details") {
            Picker("Type", selection: $diaperType) {
                ForEach(DiaperEvent.DiaperType.allCases, id: \.self) { type in
                    Label(type.displayName, systemImage: type.icon).tag(type)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }

    @ViewBuilder
    private var milestoneFields: some View {
        Section("Milestone Details") {
            TextField("Title", text: $milestoneTitle)

            Picker("Category", selection: $milestoneCategory) {
                ForEach(MilestoneEvent.MilestoneCategory.allCases, id: \.self) { cat in
                    Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                }
            }

            TextField("Description (Optional)", text: $milestoneDescription, axis: .vertical)
                .lineLimit(2...4)
        }
    }

    private func saveChanges() {
        guard let babyId = babyViewModel.selectedBaby?.id else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                var updatedEvent = event
                updatedEvent.timestamp = timestamp
                updatedEvent.notes = notes.isEmpty ? nil : notes
                updatedEvent.updatedAt = Date()

                if var feed = updatedEvent as? FeedEvent {
                    feed.method = feedMethod
                    feed.volume = feedMethod == .bottle || feedMethod == .mixed ? feedVolume : nil
                    feed.side = feedMethod == .breast ? feedSide : nil
                    feed.duration = feedMethod == .breast || feedMethod == .mixed ? feedDuration : nil
                    feed.foodType = feedMethod == .solids ? feedFoodType : nil
                    try await EventService.shared.updateEvent(feed, for: babyId)
                } else if var sleep = updatedEvent as? SleepEvent {
                    sleep.startTime = sleepStartTime
                    sleep.endTime = sleepEndTime
                    sleep.isNightSleep = sleepIsNight
                    sleep.quality = sleepQuality
                    try await EventService.shared.updateEvent(sleep, for: babyId)
                } else if var diaper = updatedEvent as? DiaperEvent {
                    diaper.diaperType = diaperType
                    try await EventService.shared.updateEvent(diaper, for: babyId)
                } else if var milestone = updatedEvent as? MilestoneEvent {
                    milestone.title = milestoneTitle
                    milestone.category = milestoneCategory
                    milestone.milestoneDescription = milestoneDescription.isEmpty ? nil : milestoneDescription
                    try await EventService.shared.updateEvent(milestone, for: babyId)
                }

                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                Logger.error("Failed to update event", error: error, category: Logger.events)
            }

            isLoading = false
        }
    }
}
