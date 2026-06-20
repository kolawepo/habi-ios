# Habi iOS

A native iOS companion to [Habi](https://habi-sepia.vercel.app), a React/Firebase habit-streak app. This isn't a full port of the web app — it's a focused exploration of three native-only iOS features, backed by the same Firebase project as the web app, with just enough surrounding app to authenticate and sync data.

## Demo

<video src="https://github.com/kolawepo/habi-ios/raw/main/docs/demo.mp4" controls width="300"></video>

If the video above doesn't render, [watch/download it directly](docs/demo.mp4).

## Features

- **Home Screen widget** — shows the current streak ("🔥 Day N") at a glance, synced from Firestore via a shared App Group store.
- **Live Activity streak countdown** — a Lock Screen banner and Dynamic Island presentation showing the streak and a live countdown to the next streak-reset deadline, updating in real time via a Firestore snapshot listener as long as the app is running. Flips to "Secured for today ✅" once a post lands.
- **Weekly Wrapped share card** — a Spotify-Wrapped-style summary (posts this week, current streak, top skill, a `Charts`-based bar chart of daily activity), rendered to an image and shared via `ShareLink`.

All three are styled with Habi's brand: cream background (`#FBF4EC`), an orange-to-pink gradient (`#FF9A6B` → `#E8553A`) on key numbers, and the Bibi bee mascot.

## Stack

- SwiftUI, WidgetKit, ActivityKit, Charts
- Firebase iOS SDK (Auth + Firestore) via Swift Package Manager
- Project structure managed with [XcodeGen](https://github.com/yonaskolb/XcodeGen) — `project.yml` is the source of truth; the generated `.xcodeproj` is gitignored

## Running it locally

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`) if you don't have it.
2. From the repo root: `xcodegen generate`
3. Add a `GoogleService-Info.plist` for an iOS app registered under the Habi Firebase project (bundle ID `com.habi.ios`) into `Habi/`. This file is gitignored since it contains real API credentials — it isn't included in this repo.
4. Open `Habi.xcodeproj` and pick a Team in Signing & Capabilities for both the `Habi` and `HabiWidgetExtension` targets (any free personal Apple ID team works for Simulator testing).
5. Run on a Simulator with Dynamic Island hardware (e.g. iPhone 16 Pro) to see all three features.

## Related

The main web app lives in a separate repo and is the source of truth for the Firestore schema (`users.streak`, `users.lastPostDate`, `posts.skill`, etc.) this app reads from.
