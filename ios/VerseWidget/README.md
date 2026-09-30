# VerseWidget (iOS WidgetKit extension)

The Swift source here is complete, but an **App Extension target cannot be
created from the command line** — it must be added once in Xcode:

1. `open ios/Runner.xcworkspace`
2. File ▸ New ▸ Target… ▸ **Widget Extension**
   - Product name: `VerseWidget` (must match `HomeWidgetService.iOSWidgetName`)
   - Uncheck "Include Configuration App Intent"
   - Don't activate the scheme when asked.
3. Delete the generated `VerseWidget.swift` / `VerseWidgetBundle.swift` and
   add this folder's `VerseWidget.swift` to the new target instead.
4. Signing & Capabilities → for **both** `Runner` and `VerseWidget` add
   **App Groups** with `group.com.versewall.bible`.
5. Set the widget target's deployment target to iOS 16.0 (lock-screen widgets).
6. Build. The Flutter side (`HomeWidgetService`) already writes
   `widget_reference`, `widget_text`, `widget_image` to that App Group and
   calls `WidgetCenter.reloadTimelines` through `home_widget`.

Data flow:

```
VOTD scheduler / background rotation ──▶ HomeWidgetService.publish(...)
        ──▶ UserDefaults(suiteName: group…) ──▶ VerseProvider.load()
```

Images are read from the app's Documents directory path stored in
`widget_image`. Because Documents is inside the app sandbox (not the group
container), image display works only while the path is readable by the
extension; if you see the gradient fallback, copy the composed image to
`FileManager.containerURL(forSecurityApplicationGroupIdentifier:)` instead.
