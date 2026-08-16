import Foundation

enum ContrastMath {
    static func relativeLuminance(_ color: RGBColor) -> Double {
        func linearize(_ channel: Double) -> Double {
            channel <= 0.04045 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
        }
        let r = linearize(color.red)
        let g = linearize(color.green)
        let b = linearize(color.blue)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    static func contrastRatio(_ a: RGBColor, _ b: RGBColor) -> Double {
        let first = relativeLuminance(a)
        let second = relativeLuminance(b)
        let lighter = max(first, second)
        let darker = min(first, second)
        return (lighter + 0.05) / (darker + 0.05)
    }

    static func reading(foreground: RGBColor, background: RGBColor) -> ContrastReading {
        ContrastReading(foreground: foreground, background: background)
    }
}

struct ContrastReading: Hashable, Sendable {
    var foreground: RGBColor
    var background: RGBColor

    var ratio: Double {
        ContrastMath.contrastRatio(foreground, background)
    }

    var formattedRatio: String {
        String(format: "%.2f:1", ratio)
    }

    var passesAANormal: Bool { ratio >= 4.5 }
    var passesAALarge: Bool { ratio >= 3.0 }
    var passesAAANormal: Bool { ratio >= 7.0 }
    var passesAAALarge: Bool { ratio >= 4.5 }

    var grade: ContrastGrade {
        if passesAAANormal { return .excellent }
        if passesAANormal { return .good }
        if passesAALarge { return .caution }
        return .poor
    }

    var plainLanguage: String {
        switch grade {
        case .excellent:
            return "Easy to tell apart, even on small labels or fine thread."
        case .good:
            return "Solid for most labels, stitching, and painted lettering."
        case .caution:
            return "OK for large lettering or bold paint, risky for small type."
        case .poor:
            return "These colors may blend together. Try a darker or lighter partner."
        }
    }

    var craftAdvice: String {
        switch grade {
        case .excellent:
            return "A strong pairing for tags, signs, and high-visibility stitching."
        case .good:
            return "Works for workshop labels and most indoor signage."
        case .caution:
            return "Use for oversized numbers or thick paint strokes, not fine print."
        case .poor:
            return "Swap thread, add an outline, or pick a higher-contrast backing."
        }
    }
}

enum ContrastGrade: String, Hashable, Sendable {
    case excellent
    case good
    case caution
    case poor

    var title: String {
        switch self {
        case .excellent: "Easy to tell apart"
        case .good: "Readable"
        case .caution: "Large marks only"
        case .poor: "May blend"
        }
    }

    var symbolName: String {
        switch self {
        case .excellent: "checkmark.seal.fill"
        case .good: "checkmark.circle.fill"
        case .caution: "exclamationmark.triangle.fill"
        case .poor: "xmark.octagon.fill"
        }
    }
}
