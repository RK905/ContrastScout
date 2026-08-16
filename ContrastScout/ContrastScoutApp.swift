import SwiftData
import SwiftUI

@main
struct ContrastScoutApp: App {
    @State private var unlockStore = UnlockStore()
    @State private var session = ScoutSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(unlockStore)
                .environment(session)
                .preferredColorScheme(.light)
                .task {
                    await unlockStore.load()
                }
        }
        .modelContainer(for: SavedSwatch.self)
    }
}
