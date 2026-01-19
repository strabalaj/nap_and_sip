import SwiftUI

struct DiaperLogView: View {
    @EnvironmentObject var babyViewModel: BabyViewModel
    @StateObject private var viewModel = QuickLogViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var diaperType: DiaperEvent.DiaperType = .wet
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Diaper Type") {
                    Picker("Type", selection: $diaperType) {
                        ForEach(DiaperEvent.DiaperType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
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
            .navigationTitle("Log Diaper")
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
            await viewModel.logDiaper(
                babyId: babyId,
                type: diaperType,
                notes: notes.isEmpty ? nil : notes
            )

            if viewModel.errorMessage == nil {
                dismiss()
            }
        }
    }
}

#Preview {
    DiaperLogView()
        .environmentObject(BabyViewModel())
}
