import SwiftUI

struct SettingsView: View {
    @Environment(UnlockStore.self) private var unlockStore
    @State private var showPaywall = false

    private let privacyURL = AppLinks.privacy
    private let supportURL = AppLinks.support
    private let marketingURL = AppLinks.website

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                NotebookCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Scout Unlock")
                            .font(.headline)
                        Text(unlockStore.isUnlocked
                             ? "Unlimited palettes and shareable reports are on."
                             : "One-time \(unlockStore.priceText) unlock for unlimited saved swatches and text reports.")
                            .font(.subheadline)
                            .foregroundStyle(ScoutTheme.inkSoft)
                        if !unlockStore.isUnlocked {
                            Button("See Scout Unlock") { showPaywall = true }
                                .buttonStyle(ScoutFilledButtonStyle())
                        }
                        Button("Restore purchases") {
                            Task { await unlockStore.restore() }
                        }
                        .buttonStyle(ScoutOutlineButtonStyle())
                    }
                }

                NotebookCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How camera sampling works")
                            .font(.headline)
                        Text("The camera is used only to read colors from physical materials such as labels, thread, paint, and signage. Frames are processed on your iPhone or iPad. Contrast Scout does not upload photos or create an account.")
                            .font(.subheadline)
                            .foregroundStyle(ScoutTheme.inkSoft)
                    }
                }

                NotebookCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estimates, not certification")
                            .font(.headline)
                        Text(ScoutTheme.disclaimer)
                            .font(.subheadline)
                            .foregroundStyle(ScoutTheme.inkSoft)
                        Text("Lighting, shadows, gloss, and camera white balance can change a reading. Use Contrast Scout as a workshop notebook, not as ADA, OSHA, or WCAG certification.")
                            .font(.subheadline)
                            .foregroundStyle(ScoutTheme.inkSoft)
                    }
                }

                NotebookCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Link("Privacy Policy", destination: privacyURL)
                        Link("Support", destination: supportURL)
                        Link("Marketing site", destination: marketingURL)
                        Text("Contrast Scout 1.0")
                            .font(.caption)
                            .foregroundStyle(ScoutTheme.stitch)
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(ScoutTheme.forest)
                }
            }
            .padding(20)
        }
        .background(PaperBackground())
        .navigationTitle("More")
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .task {
            await unlockStore.load()
        }
    }
}

struct PaywallView: View {
    @Environment(UnlockStore.self) private var unlockStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Keep the whole notebook")
                            .font(.largeTitle.bold())
                        Text("Scout Unlock is a one-time purchase. It is not a subscription.")
                            .font(.title3)
                            .foregroundStyle(ScoutTheme.inkSoft)

                        VStack(alignment: .leading, spacing: 10) {
                            benefit("Unlimited saved swatches", "The free notebook stops at \(PaletteLimits.freeSwatchCap).")
                            benefit("Shareable text reports", "Send HEX values, ratios, and craft notes to a shop partner.")
                            benefit("On-device only", "No account. Purchases restore with your Apple ID.")
                        }

                        if let message = unlockStore.errorMessage {
                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(ScoutTheme.terracotta)
                        }

                        Button {
                            Task {
                                await unlockStore.purchase()
                                if unlockStore.isUnlocked { dismiss() }
                            }
                        } label: {
                            Text(unlockStore.isLoading ? "Working…" : "Unlock for \(unlockStore.priceText)")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ScoutFilledButtonStyle())
                        .disabled(unlockStore.isLoading)

                        Button("Restore purchases") {
                            Task { await unlockStore.restore() }
                        }
                        .buttonStyle(ScoutOutlineButtonStyle())

                        Text("Payment is charged to your Apple ID. If you already bought Scout Unlock, use Restore Purchases. Privacy Policy and Support are linked in More.")
                            .font(.caption)
                            .foregroundStyle(ScoutTheme.stitch)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Scout Unlock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task { await unlockStore.load() }
        }
    }

    private func benefit(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: "checkmark.circle.fill")
                .foregroundStyle(ScoutTheme.forest)
                .font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(ScoutTheme.inkSoft)
        }
    }
}
