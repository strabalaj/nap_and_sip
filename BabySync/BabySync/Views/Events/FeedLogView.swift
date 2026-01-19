import SwiftUI

struct FeedLogView: View {
    @EnvironmentObject var babyViewModel: BabyViewModel
    @StateObject private var viewModel = QuickLogViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var method: FeedEvent.FeedMethod = .bottle
    @State private var volume: Double = 4
    @State private var side: FeedEvent.BreastSide = .left
    @State private var duration: Int = 15
    @State private var foodType = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Feed Type") {
                    Picker("Method", selection: $method) {
                        ForEach(FeedEvent.FeedMethod.allCases, id: \.self) { m in
                            Text(m.displayName).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                switch method {
                case .bottle:
                    Section("Details") {
                        HStack {
                            Text("Volume")
                            Spacer()
                            Text("\(volume, specifier: "%.1f") oz")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $volume, in: 0.5...12, step: 0.5)
                    }

                case .breast:
                    Section("Details") {
                        Picker("Side", selection: $side) {
                            ForEach(FeedEvent.BreastSide.allCases, id: \.self) { s in
                                Text(s.displayName).tag(s)
                            }
                        }
                        .pickerStyle(.segmented)

                        Stepper("Duration: \(duration) min", value: $duration, in: 1...60)
                    }

                case .solids:
                    Section("Details") {
                        TextField("Food Type (e.g., oatmeal, banana)", text: $foodType)
                    }

                case .mixed:
                    Section("Bottle") {
                        HStack {
                            Text("Volume")
                            Spacer()
                            Text("\(volume, specifier: "%.1f") oz")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $volume, in: 0.5...12, step: 0.5)
                    }
                    Section("Nursing") {
                        Stepper("Duration: \(duration) min", value: $duration, in: 1...60)
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
            .navigationTitle("Log Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
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
            await viewModel.logFeed(
                babyId: babyId,
                method: method,
                volume: method == .bottle || method == .mixed ? volume : nil,
                side: method == .breast ? side : nil,
                duration: method == .breast || method == .mixed ? duration : nil,
                foodType: method == .solids ? foodType : nil,
                notes: notes.isEmpty ? nil : notes
            )

            if viewModel.errorMessage == nil {
                dismiss()
            }
        }
    }
}

#Preview {
    FeedLogView()
        .environmentObject(BabyViewModel())
}
