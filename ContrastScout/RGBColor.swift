import SwiftUI
import UIKit

struct RGBColor: Codable, Hashable, Sendable {
    var red: Double
    var green: Double
    var blue: Double

    init(red: Double, green: Double, blue: Double) {
        self.red = Self.clamp(red)
        self.green = Self.clamp(green)
        self.blue = Self.clamp(blue)
    }

    init(uiColor: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.init(red: Double(r), green: Double(g), blue: Double(b))
    }

    init?(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6, let value = UInt32(cleaned, radix: 16) else { return nil }
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }

    var hex: String {
        String(
            format: "#%02X%02X%02X",
            Int((red * 255).rounded()),
            Int((green * 255).rounded()),
            Int((blue * 255).rounded())
        )
    }

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }

    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    var luminance: Double {
        ContrastMath.relativeLuminance(self)
    }

    func mixed(with other: RGBColor, amount: Double) -> RGBColor {
        let t = Self.clamp(amount)
        return RGBColor(
            red: red + (other.red - red) * t,
            green: green + (other.green - green) * t,
            blue: blue + (other.blue - blue) * t
        )
    }

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}

struct ColorSample: Hashable, Sendable {
    var color: RGBColor
    var label: String
    var source: SampleSource

    enum SampleSource: String, Codable, Hashable, Sendable {
        case camera
        case photo
        case picker
        case example
    }
}

enum CraftExamples {
    static let navyLabel = ColorSample(
        color: RGBColor(red: 0.102, green: 0.165, blue: 0.290),
        label: "Navy label",
        source: .example
    )
    static let creamThread = ColorSample(
        color: RGBColor(red: 0.945, green: 0.898, blue: 0.784),
        label: "Cream thread",
        source: .example
    )
    static let barnRed = ColorSample(
        color: RGBColor(red: 0.690, green: 0.188, blue: 0.149),
        label: "Barn-red paint",
        source: .example
    )
    static let sageSign = ColorSample(
        color: RGBColor(red: 0.545, green: 0.647, blue: 0.510),
        label: "Sage signage",
        source: .example
    )
}
