import UIKit

/// LANGUAGE OF CONTENT — Partial tier (BB40109 "Language of content does not match app language").
///
/// The app is English. The heading and description are English; the switch, field and button
/// were left in French with nothing declared, so VoiceOver reads them in the English voice.
///
/// Elements covered (5):
///   1. Heading      "Account settings"                     — English, "en"   → BB40112 Pass
///   2. Description  "Change your preferences below. …"     — English, "en"   → BB40112 Pass
///   3. Switch       "Recevoir les notifications"           — French, nothing → BB40109 Fail
///   4. Text field   "Nom d'utilisateur"                    — French, nothing → BB40109 Fail
///   5. Button       "Enregistrer les modifications"        — French, nothing → BB40109 Fail
final class AccessibleLanguageContentPartialViewController: LanguageContentCardViewController {
    override var screenTitle: String { "Settings (Partial)" }
    override var heading: Text { Text(string: "Account settings", language: "en") }
    override var body: Text {
        Text(string: "Change your preferences below. Your changes are saved straight away.", language: "en")
    }
    override var switchName: Text { Text(string: "Recevoir les notifications", language: nil) }
    override var fieldName: Text { Text(string: "Nom d'utilisateur", language: nil) }
    override var saveTitle: Text { Text(string: "Enregistrer les modifications", language: nil) }
    override var savedMessage: Text { Text(string: "Vos modifications ont été enregistrées.", language: nil) }
}
