import Foundation
import SwiftData

@Model
final class Settings {
    var onboardingComplete: Bool
    var dateOfBirth: Date?

    init(onboardingComplete: Bool = false, dateOfBirth: Date? = nil) {
        self.onboardingComplete = onboardingComplete
        self.dateOfBirth = dateOfBirth
    }

    var ageInYears: Double {
        guard let dob = dateOfBirth else { return 30 }
        return max(1, Date().timeIntervalSince(dob) / (365.25 * 86_400))
    }

    /// Janet's law: each new year is a smaller fraction of life lived.
    /// Younger users get a larger multiplier on their daily contributions.
    var lifetimeBaseMultiplier: Double { 100.0 / ageInYears }
}
