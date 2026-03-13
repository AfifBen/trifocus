![Flutter](https://img.shields.io/badge/flutter-%3E%3D3.0-02569B?logo=flutter&logoColor=white)
![License: MIT](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-MVP-yellow)
![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios-blue)

# TriFocus

A minimal productivity app built around the **Rule of 3**:
- Pick **3 objectives** for today
- Run **focus sessions** (with breaks)
- Track progress, streaks, and history

> Built with Flutter + Riverpod + GoRouter.

## Features

- **Today (Rule of 3)**: always shows 3 objective slots
- **Focus timer** + **Break timer** (configurable)
- **Session completion** increments objective progress
- **Library** (Projects / Habits / Paths) with add / rename / delete
- **Stats** (streak + derived metrics)
- **History**: focus session log
- **Settings**:
  - Focus/Break duration
  - Reset today progress
  - Clear history
  - Clear all data
  - Export/Import backup (JSON)
- **Daily local reminder notification**

## Tech Stack

- Flutter
- Riverpod
- go_router
- shared_preferences
- flutter_local_notifications

## Project Structure

High-level:

- `lib/app/` — app bootstrap, router, theme
- `lib/features/` — feature-first modules
  - `today/` — Rule of 3 dashboard
  - `goals/` — objectives
  - `focus_session/` — focus + break timers
  - `library/` — projects/habits/paths
  - `stats/` — streak + derived stats
  - `history/` — session logs
  - `settings/` — settings + backup tools
  - `notifications/` — daily reminder

## Getting Started

### Prerequisites

- Flutter SDK (stable)
- Android Studio / Xcode (for device tooling)

### Run

```bash
flutter pub get
flutter run
```

### Clean rebuild

```bash
flutter clean
flutter pub get
flutter run
```

## Notes

- On Android 13+, the app requests notification permission for reminders.
- If you want to test the “first run” onboarding flow, clear app data or reinstall.

## Roadmap (short)

- Widgets (Android)
- Push notifications (FCM)
- More analytics and UX polish

## GitHub Pages

A simple landing page is deployed via GitHub Pages:
- https://afifben.github.io/trifocus

## License

MIT
