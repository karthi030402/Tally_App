# Tally

A SwiftUI habit tracker for iOS 17+, built with MVVM (`@Observable`), SwiftData and async/await. It has no Combine and no third-party dependencies. It uses the "colorful daybreak" palette.

## Status

Phase 1 (core models, app screens and persistence) is done. Widgets, App Intents, reminders and accessibility work are still to come. See [Roadmap](#roadmap).

## Features

- **Today:** log habits for the day. Check-off habits toggle, and goal habits step toward a target.
- **Insights:**
  - A daily completion chart.
  - A month calendar with progress rings.
  - A weekly report, with best and worst habits.
  - A streaks card showing each habit's current and best streak.
- **Habits:**
  - A list of active and archived habits.
  - A ⋯ options sheet with Archive, Unarchive and Delete.
  - Add and edit flow.
- **Habit detail:**
  - A header, streak stats, completion rates (7 days, 30 days and all time) and total logged.
  - A month-paged ring calendar with a selected-day card.
  - Edit, archive and delete from the page. Archived habits are view-only.
- **Persistence:** SwiftData keeps habits and logs on disk. They survive relaunch.

## Habit rules

- There are two kinds of habit, check-off and goal (counter). The kind is locked after creation.
- Edits to goal, step, unit and schedule apply from today. Past days keep the rules they had. Name, color and icon apply to every day.
- Archiving is dated. Archived days aren't due, past days still count, and restoring resumes from the restore day.
- Delete is permanent. It removes the habit and its logs, and asks for confirmation first.
- Streaks count only due days, and today stays pending until it's met.
- On Insights, the daily value is the average of partial progress. The weekly report counts days met out of days due.

## Architecture

```
Tally.xcodeproj
Tally/              App target: views, view models, components, theme, stores
TallyCore/          Swift package
  TallyCore         Models and logic: HabitModel, HabitRule, progress, insights, streaks
  TallyStorage      Persistence: HabitRepository protocol, SwiftData and in-memory repositories
TallyTests/         App unit tests
TallyUITests/       UI tests
```

- **Models are structs.** `HabitModel` carries effective-dated rule revisions, so history stays correct after edits.
- **`HabitStore`** is `@MainActor @Observable` and the single source of truth. It writes through a `HabitRepository`.
- **Repositories:** `SwiftDataHabitRepository` is used by the app. `InMemoryHabitRepository` is used by previews and tests. The SwiftData record types are internal to `TallyStorage`.
- **Navigation:** `NavigationStack(path:)` with the `HabitsRoute` enum.
- **Sample data:** debug builds seed 84 days of sample history once. Release builds start empty.

## Build and test

Requires Xcode with the iOS 26 SDK.

```sh
# Package tests (models, insights, streaks, storage)
cd TallyCore
xcodebuild test -scheme TallyCore-Package -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
```

App tests run from Xcode (Cmd+U) on the `Tally` scheme.

## Roadmap

1. ~~TallyCore models and tests~~
2. ~~App: Today, Insights, Habits, add/edit, habit detail, SwiftData persistence~~
3. Widgets and App Intents (the App Group move happens here)
4. Charts and reminders
5. Accessibility, UI tests and TestFlight

## Known limits

- The launch load runs on the main actor and hasn't been measured with a year of data.
- If the database fails to load in a release build, the app silently falls back to an in-memory store.
- Past days can't be backfilled.
- Light mode and large Dynamic Type haven't been checked on the newer screens.
- `Item.swift` is an unused template file.
