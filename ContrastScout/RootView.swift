import SwiftUI

enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case scout
    case notebook
    case simulate
    case more

    var id: String { rawValue }

    var title: String {
        switch self {
        case .scout: "Scout"
        case .notebook: "Notebook"
        case .simulate: "Simulate"
        case .more: "More"
        }
    }

    var symbol: String {
        switch self {
        case .scout: "viewfinder"
        case .notebook: "book.closed"
        case .simulate: "eye"
        case .more: "ellipsis.circle"
        }
    }
}

struct RootView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var section: AppSection? = .scout

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadShell
            } else {
                iPhoneShell
            }
        }
        .tint(ScoutTheme.forest)
    }

    private var iPhoneShell: some View {
        TabView(selection: Binding(
            get: { section ?? .scout },
            set: { section = $0 }
        )) {
            NavigationStack {
                ScoutView()
            }
            .tabItem { Label(AppSection.scout.title, systemImage: AppSection.scout.symbol) }
            .tag(AppSection.scout)

            NavigationStack {
                NotebookView()
            }
            .tabItem { Label(AppSection.notebook.title, systemImage: AppSection.notebook.symbol) }
            .tag(AppSection.notebook)

            NavigationStack {
                SimulateView()
            }
            .tabItem { Label(AppSection.simulate.title, systemImage: AppSection.simulate.symbol) }
            .tag(AppSection.simulate)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label(AppSection.more.title, systemImage: AppSection.more.symbol) }
            .tag(AppSection.more)
        }
    }

    private var iPadShell: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $section) { item in
                Label(item.title, systemImage: item.symbol)
                    .tag(item)
            }
            .navigationTitle("Contrast Scout")
            .listStyle(.sidebar)
        } detail: {
            NavigationStack {
                detail
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private var detail: some View {
        switch section ?? .scout {
        case .scout: ScoutView()
        case .notebook: NotebookView()
        case .simulate: SimulateView()
        case .more: SettingsView()
        }
    }
}
