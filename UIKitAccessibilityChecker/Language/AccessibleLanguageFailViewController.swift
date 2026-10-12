import UIKit

/// LANGUAGE — Fail tier.
///
/// Every piece of text has a language problem, one of each kind the rules tell apart:
///
///   no attribute        — BB40110 "Missing language attribute for content"
///   not the app's       — BB40109 "Language of content does not match app language"
///   wrong for the text  — BB40111 "Language attribute does not match the content"
///
/// Elements covered (5) — every one fails:
///   1. Greeting label   — English, nothing declared                    → BB40110
///   2. Report button    — English, nothing declared                    → BB40110
///   3. French label     — French, declared "fr": right for the text,
///                         but not the app's language                   → BB40109
///   4. Tip label        — French text declared "en"                    → BB40111
///   5. Notice label     — English text declared "de"                   → BB40111
final class AccessibleLanguageFailViewController: LanguageDemoViewController {

    override var screenTitle: String { "Language (Fail)" }

    override var items: [Item] {
        [
            Item(text: "Welcome to the wellness dashboard where your daily progress is shown", language: nil),
            Item(text: "Open the full weekly report for this month", language: nil, isButton: true),
            Item(text: "Bienvenue sur le tableau de bord où vos progrès quotidiens sont affichés", language: "fr"),
            Item(text: "N'oubliez pas de boire de l'eau et de faire de courtes pauses pendant la journée", language: "en"),
            Item(text: "All figures on this page are updated every night at midnight", language: "de"),
        ]
    }
}
