import Foundation

enum Scoring {
    static let dailyBaseline: Double = 5.0

    static func dailyNet(_ events: [LSEvent], on day: Date, calendar: Calendar = .current) -> Double {
        let start = calendar.startOfDay(for: day)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return 0 }
        return events
            .filter { $0.timestamp >= start && $0.timestamp < end }
            .reduce(0) { $0 + $1.signedWeight }
    }

    /// Clamped 0…10. Each day starts at the baseline of 5.0.
    static func dailyScore(_ events: [LSEvent], on day: Date, calendar: Calendar = .current) -> Double {
        let net = dailyNet(events, on: day, calendar: calendar)
        return min(10, max(0, dailyBaseline + net))
    }

    /// One day's deposit into the lifetime ledger, weighted by age.
    static func dailyLifetimeContribution(_ events: [LSEvent], on day: Date, multiplier: Double, calendar: Calendar = .current) -> Double {
        return (dailyScore(events, on: day, calendar: calendar) - dailyBaseline) * multiplier
    }

    /// Sum across every distinct day that has at least one event.
    static func lifetimeLedger(_ events: [LSEvent], multiplier: Double, calendar: Calendar = .current) -> Double {
        let days = Set(events.map { calendar.startOfDay(for: $0.timestamp) })
        return days.reduce(0) { $0 + dailyLifetimeContribution(events, on: $1, multiplier: multiplier, calendar: calendar) }
    }
}
