# sisu

A minimalist iOS app for measuring **Livespan** — the felt length of life via memory density.

Based on Mitch Thrower's May 2026 essay: the brain reconstructs time from memory; routine compresses, novelty expands. Most longevity tools measure how *long* you live. sisu measures how long it *feels*.

## How it works

- **Daily 0–10 score.** Each morning you wake at **5.0**. Tap **New** when you do something genuinely new — the day climbs toward 10 (*felt long*). Tap **Faded** for autopilot time — it falls toward 0 (*disappeared*). Resets at midnight. The score is the game loop.

- **Lifetime ledger, weighted by age.** Each day's contribution to the long arc is `(dailyScore − 5) × multiplier`, where `multiplier = 100 / age`. Younger years count more, because each new year is a bigger fraction of life lived (Janet's law).
  - Age 20 → ×5.0 per day
  - Age 40 → ×2.5 per day
  - Age 60 → ×1.7 per day

- **No blocking, no streaks, no notifications.** sisu doesn't restrict apps. It just makes the cost of an unremembered day visible.

## v1 ships

- 2-step onboarding (wordmark → birthday picker)
- TodayView with daily 0–10 hero, lifetime ledger, manual ±1 controls, event list
- SwiftData persistence (`LSEvent`, `Settings`)
- Reset Onboarding from the ⋯ menu

## Deferred (deliberately)

- **Dynamic Island Live Activity.** Needs a Widget Extension Xcode target. Add via *File → New → Target → Widget Extension* in Xcode, then we can wire the Activity to mirror the daily score and speak a single situational line on threshold crossings.
- **Passive sensors.** Location (novelty places), HealthKit (workouts), Family Controls (screentime decay) — all replace the manual ± buttons with ambient capture.
- **Sunday digest** and weekly history.

## Stack

SwiftUI · SwiftData · iOS 17+

## Run

Open `sisu.xcodeproj` in Xcode. Pick an iPhone 16+ simulator. Build & run.

Step through onboarding, set your birthday. On TodayView, tap **New** or **Faded** to move the day. The lifetime ledger updates against your age multiplier. Use ⋯ → *Reset Onboarding* to re-run the birthday step.
