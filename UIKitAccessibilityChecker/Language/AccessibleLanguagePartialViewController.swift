import UIKit

/// LANGUAGE — Partial tier.
///
/// Some text is declared correctly and some is not.
///
/// Elements covered (5):
///   1. Welcome label    — English, "en"                                → BB40112 Pass
///   2. Summary label    — English, "en-US"                             → BB40112 Pass
///   3. Reminder label   — English, nothing declared                    → BB40110 Fail
///   4. French label     — French, "fr": right, but not the app's       → BB40109 Fail
///   5. Spanish label    — Spanish, "es": right, but not the app's      → BB40109 Fail
final class AccessibleLanguagePartialViewController: LanguageDemoViewController {

    override var screenTitle: String { "Language (Partial)" }

    override var items: [Item] {
        [
            Item(text: "Welcome to the wellness dashboard where your daily progress is shown", language: "en"),
            Item(text: "Your weekly summary is ready and shows how many workouts you completed", language: "en-US"),
            Item(text: "Remember to drink water and take short walking breaks during the day", language: nil),
            Item(text: "Bienvenue sur le tableau de bord où vos progrès quotidiens sont affichés", language: "fr"),
            Item(text: "Bienvenido al panel de bienestar donde se muestra tu progreso diario", language: "es"),
        ]
    }
}
