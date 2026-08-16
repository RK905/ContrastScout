import SwiftData
import SwiftUI

struct NotebookView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ScoutSession.self) private var session
    @Environment(UnlockStore.self) private var unlockStore
    @Query(sort: \SavedSwatch.createdAt, order: .reverse) private var swatches: [SavedSwatch]
    @State private var showPaywall = false
    @State private var newName = ""
    @State private var saveTarget: ScoutSession.SampleSlot = .a
    @State private var showSaveSheet = false

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if swatches.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(swatches) { swatch in
                            SwatchCard(swatch: swatch) {
                                session.assign(swatch.sample, to: .a)
                            } onUseAsB: {
                                session.assign(swatch.sample, to: .b)
                            } onDelete: {
                                modelContext.delete(swatch)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(PaperBackground())
        .navigationTitle("Notebook")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save current") {
                    if unlockStore.canSave(currentCount: swatches.count) {
                        showSaveSheet = true
                    } else {
                        showPaywall = true
                    }
                }
                .disabled(session.sampleA == nil && session.sampleB == nil)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showSaveSheet) {
            saveSheet
        }
    }

    private var header: some View {
        NotebookCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Physical swatches, kept on device")
                    .font(.headline)
                Text(unlockStore.isUnlocked
                     ? "Unlimited palettes. Export reports from Scout whenever you need a shop note."
                     : "Free notebook holds \(PaletteLimits.freeSwatchCap) swatches. Scout Unlock adds unlimited saves and shareable reports.")
                    .font(.subheadline)
                    .foregroundStyle(ScoutTheme.inkSoft)
                Text("\(swatches.count) saved")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ScoutTheme.forest)
            }
        }
    }

    private var emptyState: some View {
        NotebookCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your first page is blank")
                    .font(.title3.weight(.semibold))
                Text("Sample two craft colors, then save them here like paint chips in a shop notebook.")
                    .foregroundStyle(ScoutTheme.inkSoft)
                Button("Load navy label + cream thread") {
                    session.loadExamplePair()
                }
                .buttonStyle(ScoutFilledButtonStyle())
            }
        }
    }

    private var saveSheet: some View {
        NavigationStack {
            Form {
                Picker("Save", selection: $saveTarget) {
                    if session.sampleA != nil { Text("Sample A").tag(ScoutSession.SampleSlot.a) }
                    if session.sampleB != nil { Text("Sample B").tag(ScoutSession.SampleSlot.b) }
                }
                TextField("Name (thread, paint, sign)", text: $newName)
                Button("Save swatch") {
                    saveCurrent()
                }
                .disabled(nameIsEmpty)
            }
            .navigationTitle("Save swatch")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showSaveSheet = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var nameIsEmpty: Bool {
        newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveCurrent() {
        let sample = saveTarget == .a ? session.sampleA : session.sampleB
        guard let sample else { return }
        let swatch = SavedSwatch(
            name: newName.trimmingCharacters(in: .whitespacesAndNewlines),
            color: sample.color,
            source: sample.source
        )
        modelContext.insert(swatch)
        newName = ""
        showSaveSheet = false
    }
}

struct SwatchCard: View {
    let swatch: SavedSwatch
    var onUseAsA: () -> Void
    var onUseAsB: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(swatch.rgb.color)
                .frame(height: 88)
            Text(swatch.name)
                .font(.headline)
                .lineLimit(1)
            Text(swatch.rgb.hex)
                .font(.caption.monospaced())
                .foregroundStyle(ScoutTheme.inkSoft)
            HStack {
                Button("A", action: onUseAsA)
                Button("B", action: onUseAsB)
                Spacer()
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
            }
            .font(.caption.weight(.semibold))
        }
        .padding(12)
        .background(Color.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(ScoutTheme.stitch.opacity(0.18), lineWidth: 1)
        )
    }
}
