import Foundation
import SwiftData

@Model
final class SavedSwatch {
    var id: UUID
    var name: String
    var red: Double
    var green: Double
    var blue: Double
    var note: String
    var sourceRaw: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        color: RGBColor,
        note: String = "",
        source: ColorSample.SampleSource = .camera,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.red = color.red
        self.green = color.green
        self.blue = color.blue
        self.note = note
        self.sourceRaw = source.rawValue
        self.createdAt = createdAt
    }

    var rgb: RGBColor {
        RGBColor(red: red, green: green, blue: blue)
    }

    var source: ColorSample.SampleSource {
        ColorSample.SampleSource(rawValue: sourceRaw) ?? .picker
    }

    var sample: ColorSample {
        ColorSample(color: rgb, label: name, source: source)
    }
}

enum PaletteLimits {
    static let freeSwatchCap = 8
}
