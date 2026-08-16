import PhotosUI
import SwiftUI
import UIKit

struct PhotoSamplerView: View {
    var onSample: (RGBColor) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var pickerItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var probe = CGPoint(x: 0.5, y: 0.5)
    @State private var sampled: RGBColor?

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                VStack(spacing: 16) {
                    if let image {
                        GeometryReader { geo in
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let size = fittedSize(for: image, in: geo.size)
                                                let origin = CGPoint(
                                                    x: (geo.size.width - size.width) / 2,
                                                    y: (geo.size.height - size.height) / 2
                                                )
                                                let local = CGPoint(
                                                    x: (value.location.x - origin.x) / size.width,
                                                    y: (value.location.y - origin.y) / size.height
                                                )
                                                probe = CGPoint(
                                                    x: min(max(local.x, 0), 1),
                                                    y: min(max(local.y, 0), 1)
                                                )
                                                sampled = PixelSampler.color(in: image, at: probe)
                                            }
                                    )

                                let size = fittedSize(for: image, in: geo.size)
                                let origin = CGPoint(
                                    x: (geo.size.width - size.width) / 2,
                                    y: (geo.size.height - size.height) / 2
                                )
                                Circle()
                                    .stroke(ScoutTheme.gold, lineWidth: 2)
                                    .background(Circle().fill((sampled ?? RGBColor(red: 1, green: 1, blue: 1)).color).frame(width: 18, height: 18))
                                    .frame(width: 44, height: 44)
                                    .position(
                                        x: origin.x + probe.x * size.width,
                                        y: origin.y + probe.y * size.height
                                    )
                                    .allowsHitTesting(false)
                            }
                        }
                        .frame(maxHeight: 420)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                        if let sampled {
                            HStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(sampled.color)
                                    .frame(width: 36, height: 36)
                                Text(sampled.hex)
                                    .font(.title3.monospaced())
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        ContentUnavailableView(
                            "Choose a photo",
                            systemImage: "photo.on.rectangle",
                            description: Text("Pick a snapshot of thread, paint, or a label, then drag the finder to sample a color.")
                        )
                    }

                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label(image == nil ? "Choose photo" : "Choose another photo", systemImage: "photo")
                    }
                    .buttonStyle(ScoutFilledButtonStyle())

                    if sampled != nil {
                        Button("Use this color") {
                            if let sampled {
                                onSample(sampled)
                                dismiss()
                            }
                        }
                        .buttonStyle(ScoutFilledButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Sample from photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onChange(of: pickerItem) { _, item in
                Task {
                    if let item, let data = try? await item.loadTransferable(type: Data.self) {
                        image = UIImage(data: data)
                        if let image {
                            sampled = PixelSampler.color(in: image, at: probe)
                        }
                    }
                }
            }
        }
    }

    private func fittedSize(for image: UIImage, in container: CGSize) -> CGSize {
        let imageRatio = image.size.width / max(image.size.height, 1)
        let containerRatio = container.width / max(container.height, 1)
        if imageRatio > containerRatio {
            let width = container.width
            return CGSize(width: width, height: width / imageRatio)
        }
        let height = container.height
        return CGSize(width: height * imageRatio, height: height)
    }
}

struct ColorPickerSheet: View {
    @Binding var color: Color
    var onUse: (RGBColor) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var hexText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                VStack(alignment: .leading, spacing: 20) {
                    ColorPicker("Craft color", selection: $color, supportsOpacity: false)
                        .labelsHidden()
                        .scaleEffect(1.4)
                        .frame(maxWidth: .infinity, minHeight: 80)

                    TextField("Hex like #2F6F4E", text: $hexText)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(.body.monospaced())
                        .padding()
                        .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 12))
                        .onSubmit(applyHex)

                    Button("Use picker color") {
                        onUse(RGBColor(uiColor: UIColor(color)))
                        dismiss()
                    }
                    .buttonStyle(ScoutFilledButtonStyle())

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Color picker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func applyHex() {
        if let rgb = RGBColor(hex: hexText) {
            color = rgb.color
            onUse(rgb)
            dismiss()
        }
    }
}
