# BabySync - Technical Architecture

## System Overview

BabySync follows a client-server architecture with real-time synchronization capabilities. The iOS app serves as the client, Firebase provides the backend infrastructure, and Cloud Functions handle server-side logic including AI processing.

```
┌─────────────────────────────────────────────────────────────┐
│                     iOS App (SwiftUI)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Views      │  │  ViewModels  │  │   Models     │     │
│  │  (SwiftUI)   │◄─┤   (Combine)  │◄─┤  (Codable)   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                  │                  │             │
│         └──────────────────┼──────────────────┘             │
│                            │                                │
│                   ┌────────▼────────┐                       │
│                   │  Firebase SDK   │                       │
│                   └────────┬────────┘                       │
└────────────────────────────┼──────────────────────────────┘
                             │ HTTPS/WebSocket
                             │
┌────────────────────────────▼──────────────────────────────┐
│                    Firebase Backend                        │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐          │
│  │   Auth     │  │ Firestore  │  │  Storage   │          │
│  └────────────┘  └────────────┘  └────────────┘          │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐          │
│  │ Functions  │  │ Analytics  │  │    FCM     │          │
│  └────────────┘  └────────────┘  └────────────┘          │
└────────────────────────────────────────────────────────────┘
```

## Application Architecture

### MVVM Pattern

**Model**: Data structures and business logic
- Codable structs for all entities
- Firebase document mapping
- Validation rules
- Computed properties for derived data

**ViewModel**: State management and business logic
- ObservableObject classes
- Published properties for reactive updates
- Firebase service integration
- Data transformation
- Error handling

**View**: SwiftUI components
- Declarative UI
- Bindings to ViewModel
- Reusable components
- Navigation handling

### Project Structure

```
BabySync/
├── App/
│   ├── BabySyncApp.swift              # App entry point
│   ├── AppDelegate.swift              # Firebase configuration
│   └── Config.swift                   # Environment config
│
├── Models/
│   ├── Baby.swift                     # Baby profile
│   ├── User.swift                     # User account
│   ├── Events/
│   │   ├── BabyEvent.swift           # Base protocol
│   │   ├── FeedEvent.swift
│   │   ├── SleepEvent.swift
│   │   ├── DiaperEvent.swift
│   │   └── MilestoneEvent.swift
│   ├── Analytics/
│   │   ├── SleepAnalytics.swift
│   │   ├── FeedingAnalytics.swift
│   │   └── WakeWindow.swift
│   └── AI/
│       ├── Insight.swift
│       └── Prediction.swift
│
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── BabyViewModel.swift
│   ├── TimelineViewModel.swift
│   ├── SleepAnalyticsViewModel.swift
│   ├── QuickLogViewModel.swift
│   └── InsightsViewModel.swift
│
├── Views/
│   ├── Authentication/
│   │   ├── LoginView.swift
│   │   ├── SignUpView.swift
│   │   └── ForgotPasswordView.swift
│   ├── Onboarding/
│   │   ├── WelcomeView.swift
│   │   └── BabySetupView.swift
│   ├── Main/
│   │   ├── TabBarView.swift
│   │   ├── HomeView.swift            # Quick log buttons
│   │   ├── TimelineView.swift
│   │   ├── AnalyticsView.swift
│   │   └── ProfileView.swift
│   ├── Events/
│   │   ├── FeedLogView.swift
│   │   ├── SleepLogView.swift
│   │   ├── DiaperLogView.swift
│   │   ├── EventDetailView.swift
│   │   └── EventEditView.swift
│   ├── Analytics/
│   │   ├── SleepAnalysisView.swift   # From mockup
│   │   ├── FeedingAnalysisView.swift
│   │   ├── ChartsView.swift
│   │   └── InsightsView.swift
│   └── Components/
│       ├── QuickLogButton.swift
│       ├── EventCard.swift
│       ├── ChartView.swift
│       ├── InsightCard.swift
│       └── DateRangeSelector.swift
│
├── Services/
│   ├── FirebaseService.swift         # Base Firebase operations
│   ├── AuthService.swift             # Authentication
│   ├── EventService.swift            # CRUD for events
│   ├── AnalyticsService.swift        # Analytics calculations
│   ├── InsightsService.swift         # AI insights & predictions
│   ├── SyncService.swift             # Real-time sync
│   ├── NotificationService.swift     # Push notifications
│   └── ExportService.swift           # PDF generation
│
├── Utilities/
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── Color+Extensions.swift
│   │   └── View+Extensions.swift
│   ├── Constants.swift
│   ├── Validators.swift
│   └── Logger.swift
│
└── Resources/
    ├── Assets.xcassets
    ├── GoogleService-Info.plist
    └── Localizable.strings
```

## Data Architecture

### Firebase Collections Structure

```
users/
├── {userId}/
    ├── email: String
    ├── displayName: String
    ├── photoURL: String?
    ├── createdAt: Timestamp
    └── sharedBabies: [String]         # Baby IDs user has access to

babies/
├── {babyId}/
    ├── name: String
    ├── dateOfBirth: Timestamp
    ├── gender: String?
    ├── photoURL: String?
    ├── owners: [String]               # User IDs with access
    ├── createdBy: String              # User ID
    └── createdAt: Timestamp

events/
├── {babyId}/
    └── events/
        ├── {eventId}/
            ├── type: String           # "feed", "sleep", "diaper", "milestone"
            ├── timestamp: Timestamp
            ├── createdBy: String      # User ID
            ├── createdAt: Timestamp
            ├── updatedAt: Timestamp
            ├── notes: String?
            ├── photoURLs: [String]?
            │
            ├── // Type-specific fields
            ├── feedData: {            # If type == "feed"
            │   method: String         # "bottle", "breast", "solids"
            │   volume: Double?        # In oz
            │   side: String?          # "left", "right", "both"
            │   duration: Int?         # In minutes
            │   foodType: String?
            │ }
            │
            ├── sleepData: {           # If type == "sleep"
            │   startTime: Timestamp
            │   endTime: Timestamp?    # Null if ongoing
            │   duration: Int?         # In minutes
            │   quality: String?       # "good", "fair", "poor"
            │   napNumber: Int?        # 1, 2, 3... for naps
            │   isNightSleep: Bool
            │ }
            │
            ├── diaperData: {          # If type == "diaper"
            │   type: String           # "wet", "dirty", "both"
            │ }
            │
            └── milestoneData: {       # If type == "milestone"
                title: String
                description: String?
                category: String       # "physical", "cognitive", "social"
              }

insights/
├── {babyId}/
    └── insights/
        ├── {insightId}/
            ├── type: String           # "pattern", "recommendation", "achievement"
            ├── title: String
            ├── description: String
            ├── confidence: Double     # 0.0 - 1.0
            ├── data: Map              # Supporting data
            ├── createdAt: Timestamp
            ├── expiresAt: Timestamp?
            └── dismissed: Bool

predictions/
├── {babyId}/
    └── predictions/
        ├── current/
            ├── nextNapTime: Timestamp
            ├── nextNapConfidence: Double
            ├── nextNapDuration: Int
            ├── nextFeedTime: Timestamp
            ├── nextFeedConfidence: Double
            └── updatedAt: Timestamp
```

### Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(babyId) {
      return isAuthenticated() &&
             request.auth.uid in get(/databases/$(database)/documents/babies/$(babyId)).data.owners;
    }

    // Users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if isAuthenticated() && request.auth.uid == userId;
    }

    // Baby profiles accessible by owners only
    match /babies/{babyId} {
      allow read, write: if isOwner(babyId);
    }

    // Events accessible by baby owners
    match /events/{babyId}/events/{eventId} {
      allow read: if isOwner(babyId);
      allow create: if isOwner(babyId) &&
                       request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if isOwner(babyId);
    }

    // Insights readable by owners, writable by Cloud Functions only
    match /insights/{babyId}/insights/{insightId} {
      allow read: if isOwner(babyId);
      allow write: if false; // Only Cloud Functions
    }

    // Predictions readable by owners, writable by Cloud Functions only
    match /predictions/{babyId}/predictions/{docId} {
      allow read: if isOwner(babyId);
      allow write: if false; // Only Cloud Functions
    }
  }
}
```

## Real-Time Synchronization

### Strategy
- **Firebase Listeners**: Real-time updates via Firestore snapshots
- **Offline Support**: Local cache with automatic sync on reconnect
- **Conflict Resolution**: Last-write-wins with server timestamps
- **Optimistic Updates**: UI updates immediately, rollback on error

### Implementation

```swift
// SyncService.swift
class SyncService {
    private var listeners: [ListenerRegistration] = []

    func observeEvents(for babyId: String) -> AnyPublisher<[BabyEvent], Error> {
        let subject = PassthroughSubject<[BabyEvent], Error>()

        let listener = db.collection("events")
            .document(babyId)
            .collection("events")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                let events = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: BabyEvent.self)
                } ?? []

                subject.send(events)
            }

        listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
}
```

## AI/ML Architecture

### Pattern Detection
- **Wake Window Analysis**: Identify optimal wake times before naps
- **Feeding Patterns**: Correlate feeding volume/timing with sleep quality
- **Sleep Consolidation**: Track progress toward longer night sleep
- **Developmental Leaps**: Detect regression/progression patterns

### Prediction Engine
- **Next Nap Prediction**: Time series analysis of historical nap times
- **Duration Prediction**: Average duration by nap number and time of day
- **Feeding Window**: Predict next feeding based on interval patterns
- **Confidence Scoring**: Statistical variance and pattern strength

### Implementation Approach

**Phase 1: Rule-Based**
```swift
// Simple rule-based predictions
func predictNextNap(events: [SleepEvent]) -> Prediction {
    let recentNaps = events.filter { $0.isNap }.prefix(7)
    let avgInterval = calculateAverageInterval(recentNaps)
    let lastWake = events.first?.endTime ?? Date()

    let predictedTime = lastWake.addingTimeInterval(avgInterval)
    let confidence = calculateConfidence(from: recentNaps)

    return Prediction(time: predictedTime, confidence: confidence)
}
```

**Phase 2: Statistical Models** (Cloud Functions)
```javascript
// Cloud Function for ML predictions
exports.generatePredictions = functions.pubsub
    .schedule('every 30 minutes')
    .onRun(async (context) => {
        const babies = await admin.firestore().collection('babies').get();

        for (const baby of babies.docs) {
            const events = await getRecentEvents(baby.id);
            const predictions = await runPredictionModel(events);

            await admin.firestore()
                .collection('predictions')
                .doc(baby.id)
                .set(predictions);
        }
    });
```

## Performance Optimization

### Data Loading
- **Pagination**: Load 50 events at a time in timeline
- **Lazy Loading**: Load analytics on demand
- **Caching**: Cache frequently accessed data locally
- **Precomputation**: Calculate daily summaries in Cloud Functions

### Query Optimization
```swift
// Efficient Firestore queries
func fetchRecentEvents(limit: Int = 50) {
    db.collection("events/\(babyId)/events")
        .order(by: "timestamp", descending: true)
        .limit(to: limit)
        .getDocuments()
}

// Composite index for complex queries
// events: timestamp (desc), type (asc)
func fetchSleepEvents(startDate: Date, endDate: Date) {
    db.collection("events/\(babyId)/events")
        .whereField("type", isEqualTo: "sleep")
        .whereField("timestamp", isGreaterThanOrEqualTo: startDate)
        .whereField("timestamp", isLessThanOrEqualTo: endDate)
        .getDocuments()
}
```

### UI Performance
- **SwiftUI Optimization**: Minimize view refreshes with Equatable
- **Image Caching**: SDWebImage for photo loading
- **Chart Rendering**: Throttle updates, use Swift Charts efficiently

## Security

### Authentication
- Email/password with Firebase Auth
- Google Sign-In option
- Password reset flow
- Email verification

### Data Privacy
- End-to-end encryption for sensitive data (future)
- Secure Firebase rules (no public read/write)
- User data isolation
- GDPR compliance (data export, deletion)

### API Security
- Cloud Functions with authentication required
- Rate limiting
- Input validation
- Secure environment variables

## Testing Strategy

### Unit Tests
- ViewModels logic
- Model validation
- Utility functions
- Service layer

### Integration Tests
- Firebase operations
- Authentication flows
- Real-time sync
- Conflict resolution

### UI Tests
- Critical user flows
- Navigation
- Form validation
- Quick-log functionality

## Monitoring & Analytics

### Firebase Analytics Events
- `event_logged`: Track event creation
- `view_analytics`: Dashboard views
- `insight_viewed`: AI insight interactions
- `prediction_accuracy`: Track prediction success
- `export_pdf`: PDF generation

### Performance Monitoring
- App startup time
- Screen load time
- Network request latency
- Crash reporting

### Error Tracking
- Crashlytics integration
- Custom error logging
- User feedback system

## Deployment

### Environments
- **Development**: Local development with Firebase emulators
- **Staging**: TestFlight beta with staging Firebase project
- **Production**: App Store release with production Firebase

### CI/CD (Future)
- GitHub Actions for automated builds
- Fastlane for code signing and deployment
- Automated testing on PRs
- TestFlight deployment on main branch

## Scalability Considerations

### Current Scale (MVP)
- Target: 100-1000 users
- Firebase free tier sufficient
- Minimal Cloud Functions usage

### Future Scale
- Optimize Firestore reads (biggest cost)
- Implement aggressive caching
- Consider Cloud Function optimization
- Monitor costs and set budgets
- Potential migration to Firestore in Datastore mode

## Dependencies

### Core
- Firebase iOS SDK (Auth, Firestore, Storage, Analytics, Crashlytics, FCM)
- SwiftUI Combine

### Optional
- SDWebImage (image caching)
- Charts framework (built-in iOS 16+)
- PDFKit (PDF generation)

## Next Implementation Steps
1. Create Xcode project with SwiftUI
2. Install Firebase SDK via SPM
3. Implement authentication flow
4. Build data models
5. Create basic UI shell
6. Implement event logging
