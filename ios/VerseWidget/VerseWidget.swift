import WidgetKit
import SwiftUI

// MARK: - Shared data written by the Flutter app via `home_widget`.

struct VerseEntry: TimelineEntry {
    let date: Date
    let reference: String
    let text: String
    let imagePath: String?

    static let placeholder = VerseEntry(
        date: .now,
        reference: "Psalm 119:105 KJV",
        text: "Thy word is a lamp unto my feet, and a light unto my path.",
        imagePath: nil
    )
}

struct VerseProvider: TimelineProvider {
    static let appGroup = "group.com.versewall.bible"

    func placeholder(in context: Context) -> VerseEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> Void) {
        completion(load())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VerseEntry>) -> Void) {
        // The app refreshes data itself (VOTD scheduler / background rotation);
        // ask WidgetKit to re-read shortly after the next midnight as a fallback.
        let entry = load()
        let midnight = Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400))
        completion(Timeline(entries: [entry], policy: .after(midnight.addingTimeInterval(60))))
    }

    private func load() -> VerseEntry {
        let d = UserDefaults(suiteName: Self.appGroup)
        let ref = d?.string(forKey: "widget_reference") ?? VerseEntry.placeholder.reference
        let text = d?.string(forKey: "widget_text") ?? VerseEntry.placeholder.text
        let img = d?.string(forKey: "widget_image")
        return VerseEntry(date: .now, reference: ref, text: text,
                          imagePath: (img?.isEmpty ?? true) ? nil : img)
    }
}

// MARK: - Views

struct VerseWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: VerseEntry

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.text).font(.caption2).lineLimit(3)
                Text(entry.reference).font(.caption2).bold()
            }
            .widgetURL(URL(string: "versebible://votd"))
        case .accessoryInline:
            Text(entry.reference)
        default:
            ZStack(alignment: .bottomLeading) {
                background
                LinearGradient(colors: [.clear, .black.opacity(0.75)],
                               startPoint: .top, endPoint: .bottom)
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.text)
                        .font(family == .systemSmall ? .caption : .callout)
                        .lineLimit(family == .systemSmall ? 4 : 5)
                    Text(entry.reference).font(.caption2).bold().opacity(0.9)
                }
                .foregroundStyle(.white)
                .padding(12)
            }
            .widgetURL(URL(string: "versebible://votd"))
        }
    }

    @ViewBuilder private var background: some View {
        if let path = entry.imagePath, let ui = UIImage(contentsOfFile: path) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            LinearGradient(colors: [Color(red: 0.13, green: 0.20, blue: 0.36),
                                    Color(red: 0.05, green: 0.08, blue: 0.16)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Widget

struct VerseWidget: Widget {
    let kind = "VerseWidget"   // must match HomeWidget.updateWidget(iOSName:)

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VerseProvider()) { entry in
            if #available(iOS 17.0, *) {
                VerseWidgetView(entry: entry).containerBackground(.clear, for: .widget)
            } else {
                VerseWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("Verse of the Day")
        .description("Today's verse with your current wallpaper.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge,
                            .accessoryRectangular, .accessoryInline])
    }
}

@main
struct VerseWidgetBundle: WidgetBundle {
    var body: some Widget { VerseWidget() }
}
