# Xcode Project Setup Guide

This guide walks you through creating the Xcode project for BabySync and integrating the existing Swift source files.

## Prerequisites

- Xcode 15.0 or later
- macOS Sonoma 14.0 or later
- Apple Developer account (for device testing)

## Step 1: Create New Xcode Project

1. Open Xcode
2. Select **File → New → Project** (or press ⌘⇧N)
3. Choose **iOS → App** template
4. Click **Next**

### Project Configuration

| Field | Value |
|-------|-------|
| Product Name | `BabySync` |
| Team | Your Apple Developer Team |
| Organization Identifier | `com.yourname` (e.g., `com.strabala`) |
| Bundle Identifier | Will auto-fill as `com.yourname.BabySync` |
| Interface | **SwiftUI** |
| Language | **Swift** |
| Storage | **None** (we'll use Firebase) |
| Include Tests | ✅ Checked |

5. Click **Next**
6. **Important**: Save the project in a **temporary location** (not this repo folder)

## Step 2: Configure Project Settings

### Deployment Target
1. Select the project in the navigator
2. Select the **BabySync** target
3. Under **General → Minimum Deployments**, set iOS to **16.0**

### Device Orientation
1. Under **General → Deployment Info**
2. Uncheck **Landscape Left** and **Landscape Right**
3. Keep only **Portrait** checked

### App Icons
1. Under **General → App Icons and Launch Screen**
2. Set App Icon to **AppIcon** (we'll add this later)

## Step 3: Add Firebase SDK via Swift Package Manager

1. Select **File → Add Package Dependencies...**
2. Enter the Firebase iOS SDK URL:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
3. Click **Add Package**
4. Wait for package resolution
5. Select these packages to add:
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseStorage
   - ✅ FirebaseAnalytics
   - ✅ FirebaseCrashlytics
   - ✅ FirebaseMessaging
6. Click **Add Package**

## Step 4: Replace Source Files

### Delete Default Files
1. In Xcode's Project Navigator, delete:
   - `ContentView.swift`
   - `BabySyncApp.swift`
2. Choose **Move to Trash** when prompted

### Copy Source Files
1. In Finder, navigate to this repository's `BabySync/` folder
2. Select all contents (App/, Models/, ViewModels/, Views/, Services/, Utilities/)
3. Drag into Xcode's Project Navigator under the **BabySync** folder
4. In the dialog:
   - ✅ Copy items if needed
   - ✅ Create folder references (or Create groups)
   - Target: ✅ BabySync
5. Click **Finish**

### Verify Structure
Your project navigator should show:
```
BabySync
├── App/
│   ├── BabySyncApp.swift
│   ├── ContentView.swift
│   └── Config.swift
├── Models/
│   ├── User.swift
│   ├── Baby.swift
│   ├── Events/
│   ├── Analytics/
│   └── AI/
├── ViewModels/
├── Views/
│   ├── Auth/
│   ├── Main/
│   ├── Events/
│   ├── Analytics/
│   └── Components/
├── Services/
├── Utilities/
│   └── Extensions/
└── Resources/
```

## Step 5: Add Firebase Configuration

### Download GoogleService-Info.plist
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing
3. Click **Add app → iOS**
4. Enter bundle ID: `com.yourname.BabySync`
5. Download `GoogleService-Info.plist`
6. Drag into Xcode under `BabySync/Resources/`
7. Ensure **Copy items if needed** is checked
8. Ensure target **BabySync** is selected

### Enable Firebase Services
In Firebase Console:
1. **Authentication**: Enable Email/Password sign-in
2. **Firestore Database**: Create database in production mode
3. **Storage**: Set up Cloud Storage

## Step 6: Build and Verify

1. Select an iPhone simulator (e.g., iPhone 15 Pro)
2. Press **⌘B** to build
3. Fix any import errors (usually just need to clean build folder: ⌘⇧K)
4. Press **⌘R** to run

### Expected Result
- App should launch to the Login screen
- No crashes or errors in console
- SwiftUI previews should work (⌥⌘P)

## Step 7: Move Project to Repository

Once everything builds:

1. Close Xcode
2. In Finder, copy these files from your temp project location to this repository root:
   - `BabySync.xcodeproj/` folder
   - Keep the `BabySync/` source folder as-is (already in repo)
3. Open `BabySync.xcodeproj` from the new location
4. Verify it still builds

## Troubleshooting

### "No such module 'Firebase'"
- Clean build folder: ⌘⇧K
- Reset package caches: File → Packages → Reset Package Caches
- Rebuild: ⌘B

### "Type 'X' has no member 'Y'"
- Ensure all source files are added to the target
- Select file → File Inspector → Target Membership → ✅ BabySync

### SwiftUI Previews Not Working
- Ensure you're on a Mac with Apple Silicon or Rosetta
- Try: Editor → Canvas → Refresh (⌥⌘P)

### Firebase Initialization Crash
- Verify `GoogleService-Info.plist` is in the bundle
- Check bundle ID matches Firebase config exactly

## Next Steps

After project setup:
1. ✅ Configure Firebase backend (see Issue #3)
2. ✅ Test authentication flow (see Issue #4)
3. ✅ Build core tracking UI (see Issue #5)

## File Reference

| File Count | Category |
|------------|----------|
| 3 | App Layer |
| 12 | Models |
| 4 | ViewModels |
| 17 | Views |
| 6 | Services |
| 6 | Utilities |
| **48** | **Total Swift Files** |
