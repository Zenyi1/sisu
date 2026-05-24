import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LSEvent.timestamp, order: .reverse) private var events: [LSEvent]
    @Query private var settingsList: [Settings]

    private var today: Date { Calendar.current.startOfDay(for: Date()) }
    private var todaysEvents: [LSEvent] {
        events.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: today) }
    }
    private var score: Double { Scoring.dailyScore(events, on: today) }
    private var multiplier: Double {
        settingsList.first?.lifetimeBaseMultiplier ?? (100.0 / 30.0)
    }
    private var ledger: Double { Scoring.lifetimeLedger(events, multiplier: multiplier) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    Hero(score: score, ledger: ledger)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                    Controls(onPositive: addPositive, onNegative: addNegative)
                        .padding(.horizontal, 20)

                    if todaysEvents.isEmpty {
                        EmptyState()
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today")
                                .font(.title3.weight(.semibold))
                                .padding(.horizontal, 20)
                            VStack(spacing: 8) {
                                ForEach(todaysEvents) { ev in
                                    EventCard(event: ev)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: resetOnboarding) {
                            Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle").imageScale(.large)
                    }
                }
            }
        }
    }

    private func addPositive() {
        modelContext.insert(LSEvent(sign: .positive, weight: 1.0, note: "Somewhere new"))
        try? modelContext.save()
    }

    private func addNegative() {
        modelContext.insert(LSEvent(sign: .negative, weight: 1.0, note: "The day faded a little"))
        try? modelContext.save()
    }

    private func resetOnboarding() {
        if let s = settingsList.first {
            s.onboardingComplete = false
            try? modelContext.save()
        }
    }
}

private struct Hero: View {
    let score: Double
    let ledger: Double

    private var color: Color {
        if score >= 6 { return .green }
        if score <= 4 { return .red }
        return .secondary
    }

    private var caption: String {
        switch score {
        case 7...:   "today is opening up"
        case 6...:   "felt longer today"
        case 4...:   "today's livespan"
        case 3...:   "felt shorter today"
        default:     "the day is compressing"
        }
    }

    private var ledgerText: String {
        let sign = ledger >= 0 ? "+" : "−"
        return "\(sign)\(String(format: "%.0f", abs(ledger))) lifetime livespan"
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(String(format: "%.1f", score))
                    .font(.system(size: 96, weight: .light, design: .rounded))
                    .foregroundStyle(color)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: score))
                    .animation(.smooth(duration: 0.5), value: score)
                Text("/ 10")
                    .font(.title2.weight(.light))
                    .foregroundStyle(.tertiary)
            }
            Text(caption)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(ledgerText)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.tertiary)
                .contentTransition(.numericText(value: ledger))
                .animation(.smooth(duration: 0.5), value: ledger)
                .padding(.top, 4)
        }
        .padding(.vertical, 40)
    }
}

private struct Controls: View {
    let onPositive: () -> Void
    let onNegative: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onNegative) {
                Label("Faded", systemImage: "minus")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .tint(.red)

            Button(action: onPositive) {
                Label("New", systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }
}

private struct EventCard: View {
    let event: LSEvent

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(tint.opacity(0.15)).frame(width: 38, height: 38)
                Image(systemName: event.sign == .positive ? "plus" : "minus")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(event.note)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(event.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Spacer(minLength: 12)
            Text(badge)
                .font(.callout.monospacedDigit().weight(.semibold))
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var tint: Color { event.sign == .positive ? .green : .red }
    private var badge: String {
        let prefix = event.sign == .positive ? "+" : "−"
        return "\(prefix)\(String(format: "%.1f", event.weight))"
    }
}

private struct EmptyState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(.tertiary)
            Text("Nothing recorded yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Tap New when you do something different")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 32)
        .padding(.bottom, 48)
    }
}
