import Foundation

enum ReportExporter {
    static func text(
        sampleA: ColorSample,
        sampleB: ColorSample,
        reading: ContrastReading
    ) -> String {
        """
        Contrast Scout report
        Generated \(formattedDate(Date()))

        Sample A: \(sampleA.label)
        HEX \(sampleA.color.hex)

        Sample B: \(sampleB.label)
        HEX \(sampleB.color.hex)

        Contrast ratio: \(reading.formattedRatio)
        Result: \(reading.grade.title)
        \(reading.plainLanguage)
        \(reading.craftAdvice)

        WCAG 2.x checks (estimates)
        AA normal text (4.5:1): \(reading.passesAANormal ? "pass" : "fail")
        AA large text (3:1): \(reading.passesAALarge ? "pass" : "fail")
        AAA normal text (7:1): \(reading.passesAAANormal ? "pass" : "fail")
        AAA large text (4.5:1): \(reading.passesAAALarge ? "pass" : "fail")

        Note: Readings are estimates affected by lighting, camera white balance, and surface sheen. Contrast Scout is not a safety, ADA, or WCAG certification.
        """
    }

    private static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
