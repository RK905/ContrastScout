import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        RootView()
    }
}

#Preview("iPhone") {
    RootView()
        .environment(UnlockStore())
        .environment(ScoutSession())
        .modelContainer(for: SavedSwatch.self, inMemory: true)
}

#Preview("iPad", traits: .landscapeLeft) {
    RootView()
        .environment(UnlockStore())
        .environment(ScoutSession())
        .modelContainer(for: SavedSwatch.self, inMemory: true)
}
