import AVFoundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ScoutSession {
    var sampleA: ColorSample?
    var sampleB: ColorSample?
    var selectedSlot: SampleSlot = .a
    var lastSource: ColorSample.SampleSource = .camera

    enum SampleSlot: String {
        case a
        case b
    }

    var reading: ContrastReading? {
        guard let sampleA, let sampleB else { return nil }
        return ContrastMath.reading(foreground: sampleA.color, background: sampleB.color)
    }

    func capture(_ color: RGBColor, source: ColorSample.SampleSource) {
        let sample = ColorSample(
            color: color,
            label: selectedSlot == .a ? "Sample A" : "Sample B",
            source: source
        )
        lastSource = source
        if selectedSlot == .a {
            sampleA = sample
            selectedSlot = .b
        } else {
            sampleB = sample
        }
    }

    func assign(_ sample: ColorSample, to slot: SampleSlot) {
        if slot == .a {
            sampleA = sample
        } else {
            sampleB = sample
        }
    }

    func loadExamplePair() {
        sampleA = CraftExamples.navyLabel
        sampleB = CraftExamples.creamThread
        selectedSlot = .a
    }

    func swapSamples() {
        let originalA = sampleA
        sampleA = sampleB
        sampleB = originalA
    }
}

struct ScoutView: View {
    @Environment(ScoutSession.self) private var session
    @Environment(UnlockStore.self) private var unlockStore
    @State private var camera = CameraSampler()
    @State private var showPhotoSampler = false
    @State private var showColorPicker = false
    @State private var pickerColor = Color(red: 0.18, green: 0.44, blue: 0.31)
    @State private var showPaywall = false
    @State private var sharePayload: String?

    var body: some View {
        GeometryReader { geo in
            let isWide = geo.size.width > 700
            Group {
                if isWide {
                    HStack(spacing: 20) {
                        cameraPane
                        resultPane
                            .frame(width: min(420, geo.size.width * 0.42))
                    }
                    .padding(20)
                } else {
                    VStack(spacing: 0) {
                        cameraPane
                        resultPane
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                    }
                }
            }
        }
        .background(PaperBackground())
        .navigationTitle("Scout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
        .task { await camera.requestIfNeeded() }
        .sheet(isPresented: $showPhotoSampler) {
            PhotoSamplerView { color in
                session.capture(color, source: .photo)
            }
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerSheet(color: $pickerColor) { rgb in
                session.capture(rgb, source: .picker)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(item: Binding(
            get: { sharePayload.map(SharePayload.init) },
            set: { sharePayload = $0?.text }
        )) { payload in
            ActivityView(items: [payload.text])
        }
    }

    private var cameraPane: some View {
        ZStack {
            if camera.authorization == .authorized && camera.isCameraAvailable {
                CameraPreviewView(session: camera.session)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            } else {
                cameraFallback
            }

            ReticleOverlay(liveColor: camera.liveColor)
            VStack {
                Spacer()
                captureBar
                    .padding(16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var cameraFallback: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(ScoutTheme.ink)
            .overlay {
                VStack(spacing: 14) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 42, weight: .light))
                        .foregroundStyle(ScoutTheme.gold)
                    Text(fallbackTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Sample from a photo, the color picker, or a craft example. Camera samples stay on this device.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.78))
                        .padding(.horizontal, 24)
                    HStack(spacing: 10) {
                        if camera.needsPermissionPrompt {
                            Button("Allow Camera") {
                                Task { await camera.requestPermission() }
                            }
                            .buttonStyle(ScoutFilledButtonStyle())
                        }
                        Button("Try an example") {
                            session.loadExamplePair()
                        }
                        .buttonStyle(ScoutOutlineButtonStyle())
                    }
                }
                .padding(24)
            }
    }

    private var fallbackTitle: String {
        if camera.isDenied { return "Camera is turned off" }
        if !camera.isCameraAvailable { return "No camera on this device" }
        return "Point at thread, paint, or a label"
    }

    private var captureBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SampleSlotButton(
                    title: "A",
                    sample: session.sampleA,
                    isSelected: session.selectedSlot == .a
                ) {
                    session.selectedSlot = .a
                }
                SampleSlotButton(
                    title: "B",
                    sample: session.sampleB,
                    isSelected: session.selectedSlot == .b
                ) {
                    session.selectedSlot = .b
                }
            }

            Button {
                if let live = camera.liveColor {
                    session.capture(live, source: .camera)
                } else {
                    showColorPicker = true
                }
            } label: {
                Label(
                    session.selectedSlot == .a ? "Sample color A" : "Sample color B",
                    systemImage: "plus.viewfinder"
                )
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(ScoutFilledButtonStyle())
            .disabled(camera.liveColor == nil && camera.authorization != .authorized)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var resultPane: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let reading = session.reading, let a = session.sampleA, let b = session.sampleB {
                    ContrastResultCard(sampleA: a, sampleB: b, reading: reading)
                    HStack(spacing: 10) {
                        Button {
                            session.swapSamples()
                        } label: {
                            Label("Swap", systemImage: "arrow.left.arrow.right")
                        }
                        .buttonStyle(ScoutOutlineButtonStyle())

                        Button {
                            exportReport(a: a, b: b, reading: reading)
                        } label: {
                            Label("Share report", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(ScoutFilledButtonStyle())
                    }
                } else {
                    NotebookCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sample two colors")
                                .font(.title3.weight(.semibold))
                            Text("Point the finder at a label, thread, paint chip, or sign. Save A, then B. Contrast Scout gives a ratio and a plain-language craft result.")
                                .font(.subheadline)
                                .foregroundStyle(ScoutTheme.inkSoft)
                            Text(ScoutTheme.disclaimer)
                                .font(.caption)
                                .foregroundStyle(ScoutTheme.stitch)
                        }
                    }
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if camera.isCameraAvailable, camera.authorization == .authorized {
                Button {
                    camera.toggleTorch()
                } label: {
                    Image(systemName: camera.torchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                }
                .accessibilityLabel("Toggle lamp")
            }
            Button {
                showPhotoSampler = true
            } label: {
                Image(systemName: "photo")
            }
            .accessibilityLabel("Sample from photo")
            Button {
                showColorPicker = true
            } label: {
                Image(systemName: "paintpalette")
            }
            .accessibilityLabel("Color picker")
        }
    }

    private func exportReport(a: ColorSample, b: ColorSample, reading: ContrastReading) {
        if unlockStore.isUnlocked {
            sharePayload = ReportExporter.text(sampleA: a, sampleB: b, reading: reading)
        } else {
            showPaywall = true
        }
    }
}

private extension CameraSampler {
    func requestIfNeeded() async {
        if needsPermissionPrompt {
            await requestPermission()
        } else if authorization == .authorized {
            start()
        }
    }
}

struct SampleSlotButton: View {
    let title: String
    let sample: ColorSample?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(sample?.color.color ?? Color.white.opacity(0.35))
                    .frame(width: 28, height: 28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(.white.opacity(0.7), lineWidth: 1)
                    )
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.caption.weight(.bold))
                    Text(sample?.color.hex ?? "Empty")
                        .font(.caption2.monospaced())
                }
                Spacer(minLength: 0)
            }
            .foregroundStyle(.white)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? ScoutTheme.forest.opacity(0.92) : Color.black.opacity(0.35))
            )
        }
        .buttonStyle(.plain)
    }
}

struct ReticleOverlay: View {
    var liveColor: RGBColor?

    var body: some View {
        ZStack {
            ScoutReticle()
                .stroke(ScoutTheme.gold, lineWidth: 2.5)
                .frame(width: 92, height: 92)
                .shadow(color: .black.opacity(0.35), radius: 4)
            Circle()
                .fill(liveColor?.color ?? .white.opacity(0.4))
                .frame(width: 18, height: 18)
                .overlay(Circle().stroke(.white, lineWidth: 2))
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct ScoutReticle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let arm: CGFloat = 18
        let corners = [
            (CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.minX + arm, y: rect.minY), CGPoint(x: rect.minX, y: rect.minY + arm)),
            (CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX - arm, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY + arm)),
            (CGPoint(x: rect.minX, y: rect.maxY), CGPoint(x: rect.minX + arm, y: rect.maxY), CGPoint(x: rect.minX, y: rect.maxY - arm)),
            (CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.maxX - arm, y: rect.maxY), CGPoint(x: rect.maxX, y: rect.maxY - arm))
        ]
        for corner in corners {
            path.move(to: corner.1)
            path.addLine(to: corner.0)
            path.addLine(to: corner.2)
        }
        path.addEllipse(in: rect.insetBy(dx: rect.width * 0.28, dy: rect.height * 0.28))
        return path
    }
}

struct SharePayload: Identifiable {
    let id = UUID()
    let text: String
}

struct ActivityView: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ScoutFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(ScoutTheme.forest.opacity(configuration.isPressed ? 0.8 : 1), in: Capsule())
    }
}

struct ScoutOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(ScoutTheme.forestDeep)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .stroke(ScoutTheme.forest.opacity(configuration.isPressed ? 0.4 : 0.8), lineWidth: 1.5)
            )
    }
}
