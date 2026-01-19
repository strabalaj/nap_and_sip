import SwiftUI

struct BabySetupView: View {
    @EnvironmentObject var babyViewModel: BabyViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var dateOfBirth = Date()
    @State private var gender: Baby.Gender?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Baby's Name", text: $name)

                    DatePicker(
                        "Date of Birth",
                        selection: $dateOfBirth,
                        in: ...Date(),
                        displayedComponents: .date
                    )

                    Picker("Gender (Optional)", selection: $gender) {
                        Text("Not specified").tag(nil as Baby.Gender?)
                        ForEach([Baby.Gender.male, .female, .other], id: \.self) { g in
                            Text(g.rawValue.capitalized).tag(g as Baby.Gender?)
                        }
                    }
                }

                Section {
                    Button {
                        Task {
                            await babyViewModel.createBaby(
                                name: name,
                                dateOfBirth: dateOfBirth,
                                gender: gender
                            )
                            if babyViewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    } label: {
                        if babyViewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Save Baby")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(name.isEmpty || babyViewModel.isLoading)
                }

                if let error = babyViewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Baby")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    BabySetupView()
        .environmentObject(BabyViewModel())
}
