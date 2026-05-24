import SwiftUI
import SwiftData

@main
struct sisuApp: App {
    let sharedModelContainer: ModelContainer

    init() {
        let schema = Schema([LSEvent.self, Settings.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

private struct RootView: View {
    @Query private var settingsList: [Settings]

    var body: some View {
        if settingsList.first?.onboardingComplete == true {
            TodayView()
        } else {
            OnboardingView()
        }
    }
}
