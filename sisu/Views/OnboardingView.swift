import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [Settings]

    @State private var step: Int = 0
    @State private var dob: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()

    var body: some View {
        ZStack {
            switch step {
            case 0:
                StepWordmark()
                    .transition(.opacity)
            default:
                StepBirthday(dob: $dob)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .bottom) {
            Button(action: advance) {
                Text(step == 0 ? "Continue" : "Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .animation(.easeInOut(duration: 0.25), value: step)
    }

    private func advance() {
        if step == 0 {
            step = 1
        } else {
            complete()
        }
    }

    private func complete() {
        let s = settingsList.first ?? Settings()
        if settingsList.first == nil { modelContext.insert(s) }
        s.dateOfBirth = dob
        s.onboardingComplete = true
        try? modelContext.save()
    }
}

private struct StepWordmark: View {
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text("sisu")
                    .font(.system(size: 56, weight: .light, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Measure how much of life\nyou actually remember.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            Spacer()
            Spacer()
        }
    }
}

private struct StepBirthday: View {
    @Binding var dob: Date

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            VStack(spacing: 12) {
                Text("When were you born?")
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text("We use this to weigh each day\nagainst your life.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .padding(.horizontal, 32)

            DatePicker("Date of birth", selection: $dob, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, 20)

            Spacer()
        }
    }
}
