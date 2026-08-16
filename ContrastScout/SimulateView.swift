import SwiftUI

struct SimulateView: View {
    @Environment(ScoutSession.self) private var session
    @State private var profile: ColorVisionProfile = .deuteranopia

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Simulation", selection: $profile) {
                    ForEach(ColorVisionProfile.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                Text(profile.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(ScoutTheme.inkSoft)

                if let a = session.sampleA, let b = session.sampleB {
                    simulationCard(a: a, b: b)
                } else {
                    NotebookCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sample two colors first")
                                .font(.headline)
                            Text("Simulations help you preview how a label, thread, or painted sign may look under common color-vision differences.")
                                .foregroundStyle(ScoutTheme.inkSoft)
                            Button("Load a craft example") {
                                session.loadExamplePair()
                            }
                            .buttonStyle(ScoutFilledButtonStyle())
                        }
                    }
                }

                NotebookCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What this is for")
                            .font(.headline)
                        Text("Use these previews when choosing thread on fabric, paint on wood, or vinyl on a sign — not as a medical test or a legal accessibility certificate.")
                            .font(.subheadline)
                            .foregroundStyle(ScoutTheme.inkSoft)
                        Text(ScoutTheme.disclaimer)
                            .font(.caption)
                            .foregroundStyle(ScoutTheme.stitch)
                    }
                }
            }
            .padding(20)
        }
        .background(PaperBackground())
        .navigationTitle("Simulate")
    }

    private func simulationCard(a: ColorSample, b: ColorSample) -> some View {
        let aSim = ColorVisionSimulator.simulate(a.color, profile: profile)
        let bSim = ColorVisionSimulator.simulate(b.color, profile: profile)
        let reading = ContrastMath.reading(foreground: aSim, background: bSim)

        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                simulatedSwatch("Original A", color: a.color)
                simulatedSwatch("Original B", color: b.color)
            }
            HStack(spacing: 12) {
                simulatedSwatch("\(profile.title) A", color: aSim)
                simulatedSwatch("\(profile.title) B", color: bSim)
            }
            ContrastResultCard(
                sampleA: ColorSample(color: aSim, label: "\(a.label) · simulated", source: a.source),
                sampleB: ColorSample(color: bSim, label: "\(b.label) · simulated", source: b.source),
                reading: reading
            )
        }
    }

    private func simulatedSwatch(_ title: String, color: RGBColor) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.color)
                .frame(height: 92)
            Text(title)
                .font(.caption.weight(.semibold))
            Text(color.hex)
                .font(.caption2.monospaced())
                .foregroundStyle(ScoutTheme.inkSoft)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
