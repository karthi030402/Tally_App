# Tally

A SwiftUI habit tracker for iOS 17+, built with MVVM (`@Observable`), SwiftData and async/await. It has no Combine and no third-party dependencies. It uses the "colorful daybreak" palette.

## Status

Core models, app screens, persistence, widgets and widget logging are done. Reminders, charts and accessibility work are still to come. See [Roadmap](#roadmap).

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
- **Widgets:** a "Today" widget in six sizes.
  - Home screen:
    - **Small:** a ring showing how much of today is done.
    - **Medium:** today's count and up to four habits.
    - **Large:** up to six habits, each with a button that logs it without opening the app. A goal habit adds one step, and a check-off habit toggles.
  - Lock screen: **circular** (a ring with the done count), **rectangular** (progress bar and the next unfinished habit) and **inline** (one line of text).
  - A tap opens the app on the Today tab. A tap on a habit in the medium or large widget opens that habit.
  - iOS asks for Face ID or the passcode before the app opens from the lock screen.

## Habit rules

- There are two kinds of habit, check-off and goal (counter). The kind is locked after creation.
- Edits to goal, step, unit and schedule apply from today. Past days keep the rules they had. Name, color and icon apply to every day.
- Archiving is dated. Archived days aren't due, past days still count, and restoring resumes from the restore day.
- A habit is only due from the day it was created. Earlier days aren't counted as due in Insights, so a new habit doesn't lower past numbers.
- Delete is permanent. It removes the habit and its logs, and asks for confirmation first.
- Streaks count only due days, and today stays pending until it's met.
- On Insights, the daily value is the average of partial progress. The weekly report counts days met out of days due.

## Architecture

```
Tally.xcodeproj
Tally/              App target: views, view models, components, theme, stores
TallyWidget/        Widget extension: home screen and lock screen widgets, and the log App Intent
TallyCore/          Swift package
  TallyCore         Models and logic: HabitModel, HabitRule, progress, insights, streaks, TodaySummary, DeepLink
  TallyStorage      Persistence: HabitRepository protocol, SwiftData and in-memory repositories, App Group container
TallyTests/         App unit tests
TallyUITests/       UI tests
```

- **Models are structs.** `HabitModel` carries effective-dated rule revisions, so history stays correct after edits.
- **`HabitStore`** is `@MainActor @Observable` and the single source of truth. It writes through a `HabitRepository`.
- **Repositories:** `SwiftDataHabitRepository` is used by the app. `InMemoryHabitRepository` is used by previews and tests. The SwiftData record types are internal to `TallyStorage`.
- **Navigation:** `NavigationStack(path:)` with the `HabitsRoute` enum.
- **Sample data:** debug builds seed 84 days of sample history once. Release builds start empty.
- **Shared database:** the app and the widgets read and write one SwiftData file in the App Group container (`group.com.sathappan.dev.Tally`). A store the app kept in its own folder before widgets existed is moved there once.
- **Widget data:** `TodaySummary` builds today's rows for the app and the widgets. The timeline provider and `LogHabitIntent` share one container per widget process, and the intent reads only the tapped habit and that day's logs (`loadHabit(id:)`, `loadEntries(forHabit:on:calendar:)`).
- **Deep links:** `DeepLink` builds and reads `tally://today` and `tally://habit/<id>`.
- **Staying in sync:** the app tells the widgets to reload after a change, and reloads from the database when it becomes active again.

## Build and test

Requires Xcode with the iOS 26 SDK.

```sh
# Package tests (models, insights, streaks, storage)
cd TallyCore
xcodebuild test -scheme TallyCore-Package -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
```

App tests run from Xcode (Cmd+U) on the `Tally` scheme.

To try the widgets, run the `Tally` scheme, then add "Today" from the home screen gallery (long-press, Edit, +) or from the lock screen editor (long-press, Customize). The widget families only show up in the slot they fit.

## Roadmap

1. ~~TallyCore models and tests~~
2. ~~App: Today, Insights, Habits, add/edit, habit detail, SwiftData persistence~~
3. ~~Widgets and App Intents (the App Group move happens here)~~
4. Charts and reminders
5. Accessibility, UI tests and TestFlight

## Known limits

- The launch load runs on the main actor and hasn't been measured with a year of data.
- If the database fails to load in a release build, the app silently falls back to an in-memory store.
- Past days can't be backfilled.
- Habits saved before creation dates were added count as due on every past day, so their old Insights numbers aren't corrected.
- A mis-tap on a goal habit from the widget can only be undone in the app.
- The first widget tap after iOS stops the extension is slower, because the database opens again.
- Light mode and large Dynamic Type haven't been checked on the newer screens.
- `Item.swift` is an unused template file.
