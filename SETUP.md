# BabySync - Setup Guide

## Prerequisites

### Required Software
- **macOS**: Ventura (13.0) or later
- **Xcode**: 15.0 or later
- **iOS SDK**: 16.0 or later
- **Swift**: 5.9 or later
- **Command Line Tools**: Install via `xcode-select --install`

### Required Accounts
- **Apple Developer Account**: For App Store distribution
  - Individual or Organization account
  - Cost: $99/year
  - Sign up: https://developer.apple.com
- **Firebase Account**: Free tier sufficient for MVP
  - Sign up: https://firebase.google.com
  - Link to Google account

## Step 1: Create Xcode Project

### 1.1 Create New Project
1. Open Xcode
2. File → New → Project
3. Select **iOS** → **App**
4. Configure project:
   - **Product Name**: BabySync
   - **Team**: Select your Apple Developer team
   - **Organization Identifier**: `com.yourname.babysync` (reverse domain)
   - **Bundle Identifier**: Will be `com.yourname.babysync.BabySync`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None (using Firebase)
   - **Include Tests**: ✅ Checked
5. Save to: `/Users/jeffreystrabala/Desktop/VSC_home/GitHub/nap_and_sip/BabySync`

### 1.2 Project Settings
1. Select project in navigator
2. **General** tab:
   - **Deployment Target**: iOS 16.0
   - **Supported Destinations**: iPhone only (uncheck iPad, Mac)
   - **Supports multiple windows**: Unchecked
   - **Device Orientation**: Portrait only
3. **Signing & Capabilities**:
   - **Automatically manage signing**: Checked
   - **Team**: Your Apple Developer team
   - Click **+ Capability** and add:
     - Push Notifications
     - Background Modes → Remote notifications

### 1.3 Create Folder Structure

Create these groups (folders) in Xcode:
```
BabySync/
├── App/
├── Models/
│   ├── Events/
│   ├── Analytics/
│   └── AI/
├── ViewModels/
├── Views/
│   ├── Authentication/
│   ├── Onboarding/
│   ├── Main/
│   ├── Events/
│   ├── Analytics/
│   └── Components/
├── Services/
├── Utilities/
│   └── Extensions/
└── Resources/
```

Right-click on BabySync folder → New Group → Name each folder

## Step 2: Firebase Setup

### 2.1 Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click **Add project**
3. Project name: `BabySync`
4. Enable Google Analytics: Yes (recommended)
5. Choose or create Analytics account
6. Click **Create project**

### 2.2 Add iOS App to Firebase
1. In Firebase Console, click **Add app** → **iOS**
2. Register app:
   - **iOS bundle ID**: `com.yourname.babysync.BabySync` (must match Xcode)
   - **App nickname**: BabySync iOS
   - **App Store ID**: (leave blank for now)
3. Click **Register app**

### 2.3 Download Config File
1. Download `GoogleService-Info.plist`
2. Drag file into Xcode **Resources** folder
3. ✅ **Check**: "Copy items if needed"
4. ✅ **Check**: BabySync target
5. Click **Finish**
6. Click **Next** in Firebase Console

### 2.4 Install Firebase SDK

#### Using Swift Package Manager (Recommended)
1. In Xcode: File → Add Package Dependencies
2. Enter URL: `https://github.com/firebase/firebase-ios-sdk`
3. Dependency Rule: **Up to Next Major Version** → `11.0.0`
4. Click **Add Package**
5. Select these products:
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseStorage
   - ✅ FirebaseAnalytics
   - ✅ FirebaseCrashlytics
   - ✅ FirebaseMessaging
6. Click **Add Package**

### 2.5 Initialize Firebase

Edit `BabySyncApp.swift`:

```swift
import SwiftUI
import Firebase

@main
struct BabySyncApp: App {
    // Configure Firebase
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2.6 Configure Firebase Services

#### Firestore Database
1. In Firebase Console → Build → Firestore Database
2. Click **Create database**
3. Location: Choose closest region (e.g., `us-central`)
4. Security rules: **Start in production mode**
5. Click **Create**

#### Authentication
1. In Firebase Console → Build → Authentication
2. Click **Get started**
3. **Sign-in method** tab:
   - Enable **Email/Password**
   - Enable **Google** (optional for MVP)
4. Click **Save**

#### Storage
1. In Firebase Console → Build → Storage
2. Click **Get started**
3. Security rules: **Start in production mode**
4. Location: Same as Firestore
5. Click **Done**

#### Cloud Messaging (Push Notifications)
1. In Firebase Console → Build → Cloud Messaging
2. Click on **iOS app**
3. Upload **APNs Authentication Key**:
   - Go to https://developer.apple.com/account/resources/authkeys
   - Click **+** to create new key
   - Name: "BabySync Push Notifications"
   - Enable: **Apple Push Notifications service (APNs)**
   - Download `.p8` file
   - Upload to Firebase
   - Enter **Key ID** and **Team ID** (from Apple Developer)

## Step 3: Configure Security Rules

### 3.1 Firestore Security Rules
1. In Firebase Console → Firestore → Rules tab
2. Replace default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(babyId) {
      return isAuthenticated() &&
             request.auth.uid in get(/databases/$(database)/documents/babies/$(babyId)).data.owners;
    }

    match /users/{userId} {
      allow read, write: if isAuthenticated() && request.auth.uid == userId;
    }

    match /babies/{babyId} {
      allow read, write: if isOwner(babyId);
    }

    match /events/{babyId}/events/{eventId} {
      allow read: if isOwner(babyId);
      allow create: if isOwner(babyId) && request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if isOwner(babyId);
    }

    match /insights/{babyId}/insights/{insightId} {
      allow read: if isOwner(babyId);
      allow write: if false; // Only Cloud Functions can write
    }

    match /predictions/{babyId}/predictions/{docId} {
      allow read: if isOwner(babyId);
      allow write: if false; // Only Cloud Functions can write
    }
  }
}
```

3. Click **Publish**

### 3.2 Storage Security Rules
1. In Firebase Console → Storage → Rules tab
2. Replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /babies/{babyId}/{allPaths=**} {
      allow read: if request.auth != null &&
                     request.auth.uid in firestore.get(/databases/(default)/documents/babies/$(babyId)).data.owners;
      allow write: if request.auth != null &&
                      request.auth.uid in firestore.get(/databases/(default)/documents/babies/$(babyId)).data.owners;
    }

    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click **Publish**

## Step 4: Create Firestore Indexes

For optimal query performance, create composite indexes:

1. In Firebase Console → Firestore → Indexes tab
2. Click **Add index** for each:

### Index 1: Events by type and timestamp
- **Collection**: `events/{babyId}/events`
- **Fields**:
  - `type` (Ascending)
  - `timestamp` (Descending)
- **Query scope**: Collection
- Click **Create**

### Index 2: Events by timestamp only
- **Collection**: `events/{babyId}/events`
- **Fields**:
  - `timestamp` (Descending)
- **Query scope**: Collection
- Click **Create**

## Step 5: Initial Code Implementation

### 5.1 Create Constants File

Create `Utilities/Constants.swift`:

```swift
import SwiftUI

struct K {
    // MARK: - Collections
    struct Collections {
        static let users = "users"
        static let babies = "babies"
        static let events = "events"
        static let insights = "insights"
        static let predictions = "predictions"
    }

    // MARK: - Colors (from design)
    struct Colors {
        static let primary = Color(hex: "FF8B94")
        static let secondary = Color(hex: "A8E6CF")
        static let accent = Color(hex: "FFD3B6")
        static let purple = Color(hex: "B39DDB")
        static let dark = Color(hex: "2C3E50")
        static let light = Color(hex: "F8F9FA")
    }

    // MARK: - Notifications
    struct Notifications {
        static let userDidLogin = "userDidLogin"
        static let userDidLogout = "userDidLogout"
        static let babyDidChange = "babyDidChange"
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
```

### 5.2 Create Date Extensions

Create `Utilities/Extensions/Date+Extensions.swift`:

```swift
import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var hourOfDay: Int {
        Calendar.current.component(.hour, from: self)
    }
}
```

## Step 6: Build and Test

### 6.1 Test Firebase Connection
1. In Xcode, select a simulator (iPhone 15 Pro)
2. Click **Run** (⌘R)
3. Check console for Firebase initialization message:
   ```
   [Firebase/Core][I-COR000003] App with name __FIRAPP_DEFAULT__ configured successfully
   ```

### 6.2 Verify GoogleService-Info.plist
If Firebase doesn't connect:
1. Check `GoogleService-Info.plist` is in project
2. Verify bundle ID matches
3. Clean build folder (⌘⇧K)
4. Rebuild project (⌘B)

## Step 7: Git Setup

### 7.1 Create .gitignore

Create `.gitignore` in project root:

```gitignore
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
!*.xcworkspace/contents.xcworkspacedata
*.xcworkspace/*
!*.xcworkspace/xcshareddata/
xcuserdata/
DerivedData/
*.moved-aside
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# Swift Package Manager
.build/
Packages/
Package.pins
Package.resolved

# CocoaPods
Pods/
*.lock

# Firebase
GoogleService-Info.plist

# macOS
.DS_Store

# SwiftUI Previews
*.xcscmblueprint
```

### 7.2 Initial Commit

```bash
cd /Users/jeffreystrabala/Desktop/VSC_home/GitHub/nap_and_sip
git add .
git commit -m "Initial Xcode project setup with Firebase integration"
git push origin main
```

## Step 8: Next Development Steps

### Immediate Next Tasks
1. ✅ Create data models (see DATA_MODELS.md)
2. ✅ Implement AuthService and AuthViewModel
3. ✅ Build login/signup UI
4. ✅ Create baby profile setup
5. ✅ Implement quick-log functionality

### Development Workflow
1. Create feature branch: `git checkout -b feature/auth-flow`
2. Implement feature
3. Test thoroughly
4. Commit with descriptive message
5. Push and create pull request (if working with team)
6. Merge to main

## Troubleshooting

### Firebase SDK Installation Issues
**Problem**: Package resolution fails
**Solution**:
- Delete `~/Library/Developer/Xcode/DerivedData`
- Restart Xcode
- File → Packages → Reset Package Caches

### Bundle ID Mismatch
**Problem**: Firebase not connecting
**Solution**:
- Verify bundle ID in Xcode matches Firebase Console
- Download new `GoogleService-Info.plist` if changed

### Build Errors After Adding Firebase
**Problem**: "Ambiguous use of..." errors
**Solution**:
- Import specific Firebase modules: `import FirebaseFirestore` instead of `import Firebase`

### Simulator Not Showing
**Problem**: Can't select simulator
**Solution**:
- Xcode → Settings → Platforms → Download iOS Simulator
- Restart Xcode

## Resources

### Documentation
- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Design Assets
- Use your `sleep-analysis.html` and `timeline-view.html` mockups as reference
- Color scheme already defined in Constants.swift
- Fonts: Playfair Display and DM Sans (consider SF Pro as alternative)

### Tools
- [SF Symbols](https://developer.apple.com/sf-symbols/) - Icon library
- [Figma](https://www.figma.com) - Design mockups
- [Firebase Console](https://console.firebase.google.com) - Backend management
- [App Store Connect](https://appstoreconnect.apple.com) - App distribution

## Support

For issues during setup:
1. Check Firebase Console for errors
2. Review Xcode console logs
3. Verify all steps completed
4. Check Firebase documentation
5. Stack Overflow for specific errors

## Next Steps

Once setup is complete:
1. ✅ Start implementing data models from DATA_MODELS.md
2. ✅ Reference ARCHITECTURE.md for guidance
3. ✅ Begin with authentication flow

Good luck building BabySync! 🍼
