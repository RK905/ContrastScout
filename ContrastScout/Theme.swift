import SwiftUI

enum ScoutTheme {
    static let paper = Color(red: 0.965, green: 0.945, blue: 0.910)
    static let paperDeep = Color(red: 0.925, green: 0.890, blue: 0.835)
    static let ink = Color(red: 0.110, green: 0.141, blue: 0.188)
    static let inkSoft = Color(red: 0.110, green: 0.141, blue: 0.188).opacity(0.72)
    static let forest = Color(red: 0.184, green: 0.435, blue: 0.306)
    static let forestDeep = Color(red: 0.122, green: 0.310, blue: 0.216)
    static let terracotta = Color(red: 0.769, green: 0.361, blue: 0.243)
    static let gold = Color(red: 0.769, green: 0.639, blue: 0.353)
    static let stitch = Color(red: 0.545, green: 0.478, blue: 0.380)

    static let disclaimer = "Readings are estimates affected by lighting. Contrast Scout is not a safety certification."
}

struct PaperBackground: View {
    var body: some View {
        ScoutTheme.paper
            .ignoresSafeArea()
            .overlay {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.18),
                        Color.clear,
                        ScoutTheme.paperDeep.opacity(0.35)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
    }
}

struct NotebookCard<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.72))
                    .shadow(color: ScoutTheme.ink.opacity(0.08), radius: 10, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(ScoutTheme.stitch.opacity(0.18), lineWidth: 1)
            )
    }
}
