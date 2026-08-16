import Foundation

enum ColorVisionProfile: String, CaseIterable, Identifiable, Sendable {
    case typical
    case protanopia
    case deuteranopia
    case tritanopia

    var id: String { rawValue }

    var title: String {
        switch self {
        case .typical: "Typical vision"
        case .protanopia: "Protanopia"
        case .deuteranopia: "Deuteranopia"
        case .tritanopia: "Tritanopia"
        }
    }

    var subtitle: String {
        switch self {
        case .typical: "No simulation"
        case .protanopia: "Reduced red"
        case .deuteranopia: "Reduced green"
        case .tritanopia: "Reduced blue"
        }
    }
}

enum ColorVisionSimulator {
    /// Viénot / Brettel-inspired 3x3 matrices for common dichromacy simulations.
    static func simulate(_ color: RGBColor, profile: ColorVisionProfile) -> RGBColor {
        guard profile != .typical else { return color }
        let matrix = matrix(for: profile)
        let r = color.red * matrix[0][0] + color.green * matrix[0][1] + color.blue * matrix[0][2]
        let g = color.red * matrix[1][0] + color.green * matrix[1][1] + color.blue * matrix[1][2]
        let b = color.red * matrix[2][0] + color.green * matrix[2][1] + color.blue * matrix[2][2]
        return RGBColor(red: r, green: g, blue: b)
    }

    private static func matrix(for profile: ColorVisionProfile) -> [[Double]] {
        switch profile {
        case .typical:
            return [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
        case .protanopia:
            return [
                [0.567, 0.433, 0.000],
                [0.558, 0.442, 0.000],
                [0.000, 0.242, 0.758]
            ]
        case .deuteranopia:
            return [
                [0.625, 0.375, 0.000],
                [0.700, 0.300, 0.000],
                [0.000, 0.300, 0.700]
            ]
        case .tritanopia:
            return [
                [0.950, 0.050, 0.000],
                [0.000, 0.433, 0.567],
                [0.000, 0.475, 0.525]
            ]
        }
    }
}
