# BabySync - Implementation Guide

## Phase 1: Foundation - Authentication & Data Models

This guide walks you through implementing the core features of BabySync in a logical order.

---

## Step 1: Implement Data Models

### 1.1 Create User Model

Create `Models/User.swift`:

```swift
import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var photoURL: String?
    var sharedBabies: [String] = [] // Baby IDs this user has access to
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName
        case photoURL
        case sharedBabies
        case createdAt
        case updatedAt
    }
}
```

### 1.2 Create Baby Model

Create `Models/Baby.swift`:

```swift
import Foundation
import FirebaseFirestore

struct Baby: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var dateOfBirth: Date
    var gender: Gender?
    var photoURL: String?
    var owners: [String] = [] // User IDs with access
    var createdBy: String // User ID who created
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    enum Gender: String, Codable {
        case male
        case female
        case other
    }

    // Computed properties
    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: dateOfBirth, to: Date()).day ?? 0
    }

    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: dateOfBirth, to: Date()).month ?? 0
    }

    var ageDescription: String {
        if ageInDays < 14 {
            return "\(ageInDays) days old"
        } else if ageInMonths < 12 {
            return "\(ageInMonths) months old"
        } else {
            let years = ageInMonths / 12
            let months = ageInMonths % 12
            if months == 0 {
                return "\(years) year\(years > 1 ? "s" : "") old"
            }
            return "\(years)y \(months)m old"
        }
    }
}
```

### 1.3 Create Event Models

Create `Models/Events/EventType.swift`:

```swift
import Foundation

enum EventType: String, Codable {
    case feed
    case sleep
    case diaper
    case milestone
}
```

Create `Models/Events/FeedEvent.swift`:

```swift
import Foundation
import FirebaseFirestore

struct FeedEvent: Codable, Identifiable {
    @DocumentID var id: String?
    var babyId: String
    var type: EventType = .feed
    var timestamp: Date
    var createdBy: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var notes: String?
    var photoURLs: [String]?

    // Feed-specific fields
    var method: FeedMethod
    var volume: Double? // In ounces
    var unit: VolumeUnit = .oz
    var side: BreastSide? // For breastfeeding
    var duration: Int? // In minutes
    var foodType: String? // For solids

    enum FeedMethod: String, Codable {
        case bottle
        case breast
        case solids
        case mixed
    }

    enum BreastSide: String, Codable {
        case left
        case right
        case both
    }

    enum VolumeUnit: String, Codable {
        case oz
        case ml
    }

    var displayVolume: String? {
        guard let volume = volume else { return nil }
        return "\(Int(volume)) \(unit.rawValue)"
    }

    var displayDuration: String? {
        guard let duration = duration else { return nil }
        return "\(duration) min"
    }
}
```

Create `Models/Events/SleepEvent.swift`:

```swift
import Foundation
import FirebaseFirestore

struct SleepEvent: Codable, Identifiable {
    @DocumentID var id: String?
    var babyId: String
    var type: EventType = .sleep
    var timestamp: Date
    var createdBy: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var notes: String?
    var photoURLs: [String]?

    // Sleep-specific fields
    var startTime: Date
    var endTime: Date?
    var quality: SleepQuality?
    var isNightSleep: Bool
    var napNumber: Int?

    enum SleepQuality: String, Codable {
        case excellent
        case good
        case fair
        case poor
    }

    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    var durationInMinutes: Int? {
        guard let duration = duration else { return nil }
        return Int(duration / 60)
    }

    var displayDuration: String {
        guard let minutes = durationInMinutes else { return "Ongoing" }
        let hours = minutes / 60
        let mins = minutes % 60

        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }

    var isOngoing: Bool {
        endTime == nil
    }
}
```

Create `Models/Events/DiaperEvent.swift`:

```swift
import Foundation
import FirebaseFirestore

struct DiaperEvent: Codable, Identifiable {
    @DocumentID var id: String?
    var babyId: String
    var type: EventType = .diaper
    var timestamp: Date
    var createdBy: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var notes: String?
    var photoURLs: [String]?

    var diaperType: DiaperType

    enum DiaperType: String, Codable {
        case wet
        case dirty
        case both
    }

    var displayType: String {
        switch diaperType {
        case .wet: return "Wet"
        case .dirty: return "Dirty"
        case .both: return "Wet & Dirty"
        }
    }
}
```

---

## Step 2: Implement Firebase Services

### 2.1 Create Base Firebase Service

Create `Services/FirebaseService.swift`:

```swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService()

    let db = Firestore.firestore()
    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    private init() {}

    func currentUserId() -> String? {
        currentUser?.uid
    }
}
```

### 2.2 Create Authentication Service

Create `Services/AuthService.swift`:

```swift
import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false

    private let db = Firestore.firestore()
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupAuthListener()
    }

    private func setupAuthListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.fetchUserProfile(userId: user.uid)
            } else {
                self?.currentUser = nil
                self?.isAuthenticated = false
            }
        }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String, displayName: String) async throws -> User {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)

        let newUser = User(
            id: authResult.user.uid,
            email: email,
            displayName: displayName,
            createdAt: Date(),
            updatedAt: Date()
        )

        try await db.collection(K.Collections.users)
            .document(authResult.user.uid)
            .setData(from: newUser)

        await MainActor.run {
            self.currentUser = newUser
            self.isAuthenticated = true
        }

        return newUser
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        fetchUserProfile(userId: authResult.user.uid)
    }

    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }

    // MARK: - Fetch User Profile
    private func fetchUserProfile(userId: String) {
        db.collection(K.Collections.users)
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot,
                      let user = try? snapshot.data(as: User.self) else {
                    return
                }

                DispatchQueue.main.async {
                    self?.currentUser = user
                    self?.isAuthenticated = true
                }
            }
    }

    // MARK: - Password Reset
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
```

### 2.3 Create Event Service

Create `Services/EventService.swift`:

```swift
import Foundation
import FirebaseFirestore
import Combine

class EventService: ObservableObject {
    private let db = Firestore.firestore()

    // MARK: - Create Feed Event
    func logFeedEvent(
        babyId: String,
        method: FeedEvent.FeedMethod,
        volume: Double? = nil,
        side: FeedEvent.BreastSide? = nil,
        duration: Int? = nil,
        foodType: String? = nil,
        notes: String? = nil
    ) async throws -> FeedEvent {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        let event = FeedEvent(
            babyId: babyId,
            timestamp: Date(),
            createdBy: userId,
            notes: notes,
            method: method,
            volume: volume,
            side: side,
            duration: duration,
            foodType: foodType
        )

        let ref = try db.collection(K.Collections.events)
            .document(babyId)
            .collection("events")
            .addDocument(from: event)

        var savedEvent = event
        savedEvent.id = ref.documentID
        return savedEvent
    }

    // MARK: - Create Sleep Event
    func startSleep(
        babyId: String,
        isNightSleep: Bool,
        notes: String? = nil
    ) async throws -> SleepEvent {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401)
        }

        let event = SleepEvent(
            babyId: babyId,
            timestamp: Date(),
            createdBy: userId,
            notes: notes,
            startTime: Date(),
            endTime: nil,
            isNightSleep: isNightSleep
        )

        let ref = try db.collection(K.Collections.events)
            .document(babyId)
            .collection("events")
            .addDocument(from: event)

        var savedEvent = event
        savedEvent.id = ref.documentID
        return savedEvent
    }

    func endSleep(eventId: String, babyId: String, quality: SleepEvent.SleepQuality? = nil) async throws {
        let ref = db.collection(K.Collections.events)
            .document(babyId)
            .collection("events")
            .document(eventId)

        try await ref.updateData([
            "endTime": Timestamp(date: Date()),
            "quality": quality?.rawValue ?? "",
            "updatedAt": Timestamp(date: Date())
        ])
    }

    // MARK: - Create Diaper Event
    func logDiaperChange(
        babyId: String,
        type: DiaperEvent.DiaperType,
        notes: String? = nil
    ) async throws -> DiaperEvent {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401)
        }

        let event = DiaperEvent(
            babyId: babyId,
            timestamp: Date(),
            createdBy: userId,
            notes: notes,
            diaperType: type
        )

        let ref = try db.collection(K.Collections.events)
            .document(babyId)
            .collection("events")
            .addDocument(from: event)

        var savedEvent = event
        savedEvent.id = ref.documentID
        return savedEvent
    }

    // MARK: - Fetch Events
    func observeEvents(for babyId: String) -> AnyPublisher<[AnyEvent], Error> {
        let subject = PassthroughSubject<[AnyEvent], Error>()

        db.collection(K.Collections.events)
            .document(babyId)
            .collection("events")
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                var events: [AnyEvent] = []

                snapshot?.documents.forEach { doc in
                    let data = doc.data()
                    guard let typeString = data["type"] as? String,
                          let type = EventType(rawValue: typeString) else {
                        return
                    }

                    switch type {
                    case .feed:
                        if let event = try? doc.data(as: FeedEvent.self) {
                            events.append(.feed(event))
                        }
                    case .sleep:
                        if let event = try? doc.data(as: SleepEvent.self) {
                            events.append(.sleep(event))
                        }
                    case .diaper:
                        if let event = try? doc.data(as: DiaperEvent.self) {
                            events.append(.diaper(event))
                        }
                    case .milestone:
                        break // Implement later
                    }
                }

                subject.send(events)
            }

        return subject.eraseToAnyPublisher()
    }

    // MARK: - Delete Event
    func deleteEvent(eventId: String, babyId: String) async throws {
        try await db.collection(K.Collections.events)
            .document(babyId)
            .collection("events")
            .document(eventId)
            .delete()
    }
}

// Helper enum for mixed event types
enum AnyEvent: Identifiable {
    case feed(FeedEvent)
    case sleep(SleepEvent)
    case diaper(DiaperEvent)

    var id: String {
        switch self {
        case .feed(let event): return event.id ?? ""
        case .sleep(let event): return event.id ?? ""
        case .diaper(let event): return event.id ?? ""
        }
    }

    var timestamp: Date {
        switch self {
        case .feed(let event): return event.timestamp
        case .sleep(let event): return event.timestamp
        case .diaper(let event): return event.timestamp
        }
    }
}
```

---

## Step 3: Implement Authentication UI

### 3.1 Create AuthViewModel

Create `ViewModels/AuthViewModel.swift`:

```swift
import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var displayName = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()

    var isAuthenticated: Bool {
        authService.isAuthenticated
    }

    func signUp() async {
        guard validate() else { return }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await authService.signUp(
                email: email,
                password: password,
                displayName: displayName
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signIn() async {
        guard validateLogin() else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func resetPassword() async {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.resetPassword(email: email)
            errorMessage = "Password reset email sent!"
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func validate() -> Bool {
        if displayName.isEmpty {
            errorMessage = "Please enter your name"
            return false
        }
        if email.isEmpty {
            errorMessage = "Please enter your email"
            return false
        }
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        return true
    }

    private func validateLogin() -> Bool {
        if email.isEmpty {
            errorMessage = "Please enter your email"
            return false
        }
        if password.isEmpty {
            errorMessage = "Please enter your password"
            return false
        }
        return true
    }
}
```

### 3.2 Create Login View

Create `Views/Authentication/LoginView.swift`:

```swift
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("BabySync")
                        .font(.custom("PlayfairDisplay-Bold", size: 42))
                        .foregroundColor(K.Colors.primary)

                    Text("Track, analyze, and understand your baby's patterns")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)

                Spacer()

                // Login Form
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .textContentType(.password)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task {
                            await viewModel.signIn()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, 32)

                // Sign Up Link
                Button {
                    showSignUp = true
                } label: {
                    Text("Don't have an account? **Sign Up**")
                        .font(.subheadline)
                        .foregroundColor(K.Colors.dark)
                }

                Spacer()
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}

// MARK: - Custom Styles
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(K.Colors.light)
            .cornerRadius(12)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(K.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}
```

### 3.3 Create Sign Up View

Create `Views/Authentication/SignUpView.swift`:

```swift
import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Create Account")
                        .font(.custom("PlayfairDisplay-Bold", size: 32))
                        .foregroundColor(K.Colors.dark)
                        .padding(.top, 40)

                    VStack(spacing: 16) {
                        TextField("Full Name", text: $viewModel.displayName)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .textContentType(.name)

                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        SecureField("Password (min 6 characters)", text: $viewModel.password)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .textContentType(.newPassword)

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }

                        Button {
                            Task {
                                await viewModel.signUp()
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal, 32)
                }
            }
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
```

---

## Step 4: Update App Entry Point

Update `App/BabySyncApp.swift`:

```swift
import SwiftUI
import Firebase

@main
struct BabySyncApp: App {
    @StateObject private var authService = AuthService()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}
```

---

## Step 5: Create Main Tab View (Placeholder)

Create `Views/Main/MainTabView.swift`:

```swift
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Text("Home View")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            Text("Timeline View")
                .tabItem {
                    Label("Timeline", systemImage: "clock.fill")
                }

            Text("Analytics View")
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }

            Text("Profile View")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(K.Colors.primary)
    }
}
```

---

## Next Steps

You now have:
- ✅ Complete data models for users, babies, and events
- ✅ Firebase authentication system
- ✅ Event logging service (feed, sleep, diaper)
- ✅ Login and sign-up UI
- ✅ Basic app structure

### Continue to Phase 2:
1. Implement baby profile creation
2. Build quick-log UI with buttons
3. Create timeline view
4. Add real-time event listening
5. Implement event editing/deletion

See ARCHITECTURE.md for the complete system design and refer to your HTML mockups for UI styling.
