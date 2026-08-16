import SwiftUI

struct ContrastResultCard: View {
    let sampleA: ColorSample
    let sampleB: ColorSample
    let reading: ContrastReading

    var body: some View {
        NotebookCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    SwatchChip(sample: sampleA)
                    Image(systemName: "arrow.left.and.right")
                        .foregroundStyle(ScoutTheme.stitch)
                    SwatchChip(sample: sampleB)
                }

                HStack(alignment: .firstTextBaseline) {
                    Text(reading.formattedRatio)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(ScoutTheme.ink)
                    Spacer()
                    Label(reading.grade.title, systemImage: reading.grade.symbolName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(gradeColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(gradeColor.opacity(0.12), in: Capsule())
                }

                Text(reading.plainLanguage)
                    .font(.body)
                    .foregroundStyle(ScoutTheme.ink)
                Text(reading.craftAdvice)
                    .font(.subheadline)
                    .foregroundStyle(ScoutTheme.inkSoft)

                PreviewPair(foreground: sampleA.color, background: sampleB.color)

                WCAGChecklist(reading: reading)

                Text(ScoutTheme.disclaimer)
                    .font(.caption2)
                    .foregroundStyle(ScoutTheme.stitch)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Contrast \(reading.formattedRatio), \(reading.grade.title). \(reading.plainLanguage)")
    }

    private var gradeColor: Color {
        switch reading.grade {
        case .excellent, .good: ScoutTheme.forest
        case .caution: ScoutTheme.gold
        case .poor: ScoutTheme.terracotta
        }
    }
}

struct SwatchChip: View {
    let sample: ColorSample

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(sample.color.color)
                .frame(height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(ScoutTheme.ink.opacity(0.12), lineWidth: 1)
                )
            Text(sample.label)
                .font(.caption.weight(.semibold))
            Text(sample.color.hex)
                .font(.caption2.monospaced())
                .foregroundStyle(ScoutTheme.inkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PreviewPair: View {
    let foreground: RGBColor
    let background: RGBColor

    var body: some View {
        VStack(spacing: 8) {
            labelPreview(text: "WORKSHOP", size: 13, weight: .semibold)
            labelPreview(text: "EXIT", size: 28, weight: .bold)
        }
    }

    private func labelPreview(text: String, size: CGFloat, weight: Font.Weight) -> some View {
        Text(text)
            .font(.system(size: size, weight: weight, design: .rounded))
            .foregroundStyle(foreground.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(background.color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityLabel("Preview of \(text) using sample A on sample B")
    }
}

struct WCAGChecklist: View {
    let reading: ContrastReading

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("WCAG 2.x estimates")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ScoutTheme.inkSoft)
            check("AA body / labels", pass: reading.passesAANormal, threshold: "4.5:1")
            check("AA large lettering", pass: reading.passesAALarge, threshold: "3:1")
            check("AAA body / labels", pass: reading.passesAAANormal, threshold: "7:1")
            check("AAA large lettering", pass: reading.passesAAALarge, threshold: "4.5:1")
        }
    }

    private func check(_ title: String, pass: Bool, threshold: String) -> some View {
        HStack {
            Image(systemName: pass ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(pass ? ScoutTheme.forest : ScoutTheme.terracotta)
            Text(title)
            Spacer()
            Text(threshold)
                .font(.caption.monospaced())
                .foregroundStyle(ScoutTheme.inkSoft)
        }
        .font(.subheadline)
    }
}
