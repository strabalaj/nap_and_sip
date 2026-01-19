import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var babyViewModel: BabyViewModel

    @State private var showBabySettings = false
    @State private var showSignOutAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let user = authViewModel.currentUser {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color.accentColor.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Text(user.displayName.prefix(1).uppercased())
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.accentColor)
                                }

                            VStack(alignment: .leading) {
                                Text(user.displayName)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                Section("Babies") {
                    ForEach(babyViewModel.babies) { baby in
                        HStack {
                            Text(baby.name)
                            Spacer()
                            if baby.id == babyViewModel.selectedBaby?.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            babyViewModel.selectBaby(baby)
                        }
                    }

                    Button {
                        showBabySettings = true
                    } label: {
                        Label("Add Baby", systemImage: "plus")
                    }
                }

                Section("Settings") {
                    NavigationLink {
                        Text("Notifications Settings")
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }

                    NavigationLink {
                        Text("Privacy Settings")
                    } label: {
                        Label("Privacy", systemImage: "lock")
                    }

                    NavigationLink {
                        Text("About")
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showSignOutAlert = true
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showBabySettings) {
                BabySetupView()
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(BabyViewModel())
}
