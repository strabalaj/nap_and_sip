import SwiftUI

struct SleepLogView: View {
    @EnvironmentObject var babyViewModel: BabyViewModel
    @StateObject private var viewModel = QuickLogViewModel()
    @Environment(\.dismiss) var dismiss

    let ongoingSleep: SleepEvent?

    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var isNightSleep = false
    @State private var quality: SleepEvent.SleepQuality = .good
    @State private var notes = ""
    @State private var isEndingSleep = false

    init(ongoingSleep: SleepEvent? = nil) {
        self.ongoingSleep = ongoingSleep
        if let sleep = ongoingSleep {
            _startTime = State(initialValue: sleep.startTime)
            _isNightSleep = State(initialValue: sleep.isNightSleep)
            _isEndingSleep = State(initialValue: true)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                if isEndingSleep, let sleep = ongoingSleep {
                    Section {
                        HStack {
                            Image(systemName: "moon.zzz.fill")
                                .foregroundColor(.purple)
                            Text("Sleep in progress")
                            Spacer()
                            Text(sleep.startTime.formatted(date: .omitted, time: .shortened))
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Duration so far")
                            Spacer()
                            Text(formatDuration(from: sleep.startTime, to: Date()))
                                .foregroundColor(.secondary)
                        }
                    }

                    Section("End Sleep") {
                        DatePicker("End Time", selection: $endTime, in: sleep.startTime...Date())

                        Picker("Sleep Quality", selection: $quality) {
                            ForEach(SleepEvent.SleepQuality.allCases, id: \.self) { q in
                                Text(q.displayName).tag(q)
                            }
                        }
                    }
                } else {
                    Section("Sleep Type") {
                        Toggle("Night Sleep", isOn: $isNightSleep)
                    }

                    Section("Time") {
                        DatePicker("Start Time", selection: $startTime, in: ...Date())
                    }

                    Section {
                        Text("Tip: You can also use the quick-log button on the home screen to start tracking sleep, then end it later.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Notes (Optional)") {
                    TextField("Add notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(isEndingSleep ? "End Sleep" : "Start Sleep")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEndingSleep ? "End Sleep" : "Start") {
                        saveEvent()
                    }
                    .fontWeight(.semibold)
                    .disabled(viewModel.isLoading)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }

    private func saveEvent() {
        guard let babyId = babyViewModel.selectedBaby?.id else { return }

        Task {
            if isEndingSleep, let sleep = ongoingSleep {
                await viewModel.endSleep(event: sleep, babyId: babyId, quality: quality)
            } else {
                await viewModel.startSleep(babyId: babyId, isNightSleep: isNightSleep)
            }

            if viewModel.errorMessage == nil {
                dismiss()
            }
        }
    }

    private func formatDuration(from start: Date, to end: Date) -> String {
        let interval = end.timeIntervalSince(start)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
}

#Preview("Start Sleep") {
    SleepLogView()
        .environmentObject(BabyViewModel())
}

#Preview("End Sleep") {
    SleepLogView(ongoingSleep: SleepEvent(
        babyId: "123",
        createdBy: "user1",
        startTime: Date().addingTimeInterval(-3600),
        isNightSleep: false
    ))
    .environmentObject(BabyViewModel())
}
