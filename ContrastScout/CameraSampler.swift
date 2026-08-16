import AVFoundation
import CoreVideo
import Observation
import UIKit

@MainActor
@Observable
final class CameraSampler {
    var liveColor: RGBColor?
    var isRunning = false
    var torchOn = false
    var authorization: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    var errorMessage: String?

    let session = AVCaptureSession()
    let isCameraAvailable = AVCaptureDevice.default(for: .video) != nil

    private let sessionQueue = DispatchQueue(label: "com.geeksdobyte.ContrastScout.camera")
    private let output = AVCaptureVideoDataOutput()
    private var device: AVCaptureDevice?
    private var frameSampler: CameraFrameSampler?
    private var configured = false

    var needsPermissionPrompt: Bool {
        authorization == .notDetermined
    }

    var isDenied: Bool {
        authorization == .denied || authorization == .restricted
    }

    func requestPermission() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        authorization = AVCaptureDevice.authorizationStatus(for: .video)
        if granted {
            start()
        }
    }

    func start() {
        authorization = AVCaptureDevice.authorizationStatus(for: .video)
        guard isCameraAvailable else {
            errorMessage = "No camera is available. Sample from a photo or the color picker instead."
            return
        }
        guard authorization == .authorized else { return }

        sessionQueue.async { [weak self] in
            self?.configureIfNeeded()
            guard let session = self?.session, !session.isRunning else { return }
            session.startRunning()
            Task { @MainActor in
                self?.isRunning = true
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let session = self?.session, session.isRunning else { return }
            session.stopRunning()
            Task { @MainActor in
                self?.isRunning = false
            }
        }
    }

    func toggleTorch() {
        guard let device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                device.torchMode = .off
                torchOn = false
            } else if device.isTorchModeSupported(.on) {
                try device.setTorchModeOn(level: 0.7)
                torchOn = true
            }
            device.unlockForConfiguration()
        } catch {
            errorMessage = "Could not toggle the lamp."
        }
    }

    private func configureIfNeeded() {
        if configured { return }
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                ?? AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            session.commitConfiguration()
            Task { @MainActor in
                self.errorMessage = "The camera could not be started."
            }
            return
        }

        session.addInput(input)
        device = camera

        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let sampler = CameraFrameSampler { [weak self] color in
            Task { @MainActor in
                self?.liveColor = color
            }
        }
        frameSampler = sampler
        output.setSampleBufferDelegate(sampler, queue: sessionQueue)
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        if let connection = output.connection(with: .video), connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }

        session.commitConfiguration()
        configured = true
    }
}

nonisolated final class CameraFrameSampler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    private let onSample: @Sendable (RGBColor) -> Void
    private var lastSample = Date.distantPast

    init(onSample: @escaping @Sendable (RGBColor) -> Void) {
        self.onSample = onSample
    }

    nonisolated func captureOutput(
        _ output: AVCaptureVideoDataOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let now = Date()
        guard now.timeIntervalSince(lastSample) > 0.12 else { return }
        lastSample = now
        guard let color = PixelSampler.centerColor(in: sampleBuffer) else { return }
        onSample(color)
    }
}

enum PixelSampler: Sendable {
    nonisolated static func centerColor(in sampleBuffer: CMSampleBuffer) -> RGBColor? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        return averageColor(in: pixelBuffer)
    }

    nonisolated static func averageColor(in pixelBuffer: CVPixelBuffer, radius: Int = 8) -> RGBColor? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else { return nil }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let bytes = base.assumingMemoryBound(to: UInt8.self)

        let cx = width / 2
        let cy = height / 2
        var totalR = 0
        var totalG = 0
        var totalB = 0
        var count = 0

        for y in max(0, cy - radius)..<min(height, cy + radius) {
            for x in max(0, cx - radius)..<min(width, cx + radius) {
                let offset = y * bytesPerRow + x * 4
                totalB += Int(bytes[offset])
                totalG += Int(bytes[offset + 1])
                totalR += Int(bytes[offset + 2])
                count += 1
            }
        }
        guard count > 0 else { return nil }
        return RGBColor(
            red: Double(totalR) / Double(count) / 255,
            green: Double(totalG) / Double(count) / 255,
            blue: Double(totalB) / Double(count) / 255
        )
    }

    nonisolated static func color(in image: UIImage, at normalizedPoint: CGPoint) -> RGBColor? {
        guard let cgImage = image.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        let x = min(max(Int(normalizedPoint.x * CGFloat(width)), 0), width - 1)
        let y = min(max(Int(normalizedPoint.y * CGFloat(height)), 0), height - 1)
        let radius = 6
        let crop = CGRect(
            x: max(0, x - radius),
            y: max(0, y - radius),
            width: min(radius * 2, width - max(0, x - radius)),
            height: min(radius * 2, height - max(0, y - radius))
        )
        guard crop.width > 0, crop.height > 0, let cropped = cgImage.cropping(to: crop) else { return nil }
        return averageColor(in: cropped)
    }

    nonisolated static func averageColor(in image: CGImage) -> RGBColor? {
        let width = image.width
        let height = image.height
        let bytesPerRow = width * 4
        var data = [UInt8](repeating: 0, count: height * bytesPerRow)
        guard let context = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        var totalR = 0
        var totalG = 0
        var totalB = 0
        let count = width * height
        guard count > 0 else { return nil }
        for i in 0..<count {
            let offset = i * 4
            totalR += Int(data[offset])
            totalG += Int(data[offset + 1])
            totalB += Int(data[offset + 2])
        }
        return RGBColor(
            red: Double(totalR) / Double(count) / 255,
            green: Double(totalG) / Double(count) / 255,
            blue: Double(totalB) / Double(count) / 255
        )
    }
}
