# Habi iOS

A native iOS companion to [Habi](https://habi-sepia.vercel.app), a React/Firebase social learning platform. Rather than recreating the full web app, this project focuses on three native iOS experiences — Home Screen widgets, Live Activities, and Weekly Wrapped share cards — while sharing the same Firebase backend as the web application.

## Demo

🎥 **Demo Video:**  
https://kolawepo.github.io/habi-ios/habi-ios-demo.mp4

## Features

### 🔥 Home Screen Widget

Displays the current streak ("🔥 Day N") at a glance using WidgetKit and synchronizes data from Firestore through a shared App Group store.

### ⏱️ Live Activity Streak Countdown

Shows the current streak and a live countdown to the next streak-reset deadline on the Lock Screen and Dynamic Island using ActivityKit. Automatically switches to **"Secured for today ✅"** when a new post is created.

### 📊 Weekly Wrapped Share Card

Generates a Spotify Wrapped–style summary including:

- Posts completed this week
- Current streak
- Top skill
- Charts-based daily activity graph

and exports the card as an image using `ShareLink`.

All experiences follow Habi's design system with:

- Cream background (`#FBF4EC`)
- Orange-to-pink gradient (`#FF9A6B → #E8553A`)
- Bibi bee mascot

## Stack

- SwiftUI
- WidgetKit
- ActivityKit
- Charts
- Firebase Auth
- Cloud Firestore
- XcodeGen

Project configuration is managed with **XcodeGen**, making `project.yml` the source of truth while keeping the generated `.xcodeproj` out of version control.

## Running Locally

1. Install XcodeGen

```bash
brew install xcodegen
```

2. Generate the project

```bash
xcodegen generate
```

3. Add a `GoogleService-Info.plist` for an iOS app registered under the Habi Firebase project (bundle ID `com.habi.ios`) into `Habi/`.

4. Open `Habi.xcodeproj` and select a Team in Signing & Capabilities for both the `Habi` and `HabiWidgetExtension` targets.

5. Run on a Dynamic Island simulator (e.g. iPhone 16 Pro) to experience all three features.

## Related

The main web app lives in a separate repository and serves as the source of truth for the Firestore schema (`users.streak`, `users.lastPostDate`, `posts.skill`, etc.) consumed by the iOS client.
