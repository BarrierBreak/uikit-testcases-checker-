import UIKit

/// LANGUAGE — Pass tier.
///
/// Every piece of text is in the app's language (English) and says so: each carries
/// `accessibilityLanguage = "en"` (one with a region, "en-US", which is the same language).
/// Each reports BB40112 "Language of content matches the language attribute", and the screen
/// reports BB40106 "App language is defined".
///
/// Elements covered (5) — none is a defect:
///   1. Welcome label     — "en"
///   2. Summary label     — "en"
///   3. Report button     — "en"
///   4. Reminder label    — "en-US": a region does not make it another language
///   5. Footnote label    — "en"
final class AccessibleLanguagePassViewController: LanguageDemoViewController {

    override var screenTitle: String { "Language (Pass)" }

    override var items: [Item] {
        [
            Item(text: "Welcome to the wellness dashboard where your daily progress is shown", language: "en"),
            Item(text: "Your weekly summary is ready and shows how many workouts you completed", language: "en"),
            Item(text: "Open the full weekly report for this month", language: "en", isButton: true),
            Item(text: "Remember to drink water and take short walking breaks during the day", language: "en-US"),
            Item(text: "All figures on this page are updated every night at midnight", language: "en"),
        ]
    }
}
