import UIKit

/// LANGUAGE OF CONTENT — Pass tier (BB40109 "Language of content does not match app language").
///
/// The app is English and the content is English, declared as such, so the app's voice is the
/// right one for every element.
///
/// Elements covered (5) — none fails, each BB40112 Pass:
///   heading, description, switch, text field, button — English, accessibilityLanguage "en"
final class AccessibleLanguageContentPassViewController: LanguageContentCardViewController {
    override var screenTitle: String { "Settings (Pass)" }
    override var heading: Text { Text(string: "Account settings", language: "en") }
    override var body: Text {
        Text(string: "Change your preferences below. Your changes are saved straight away.", language: "en")
    }
    override var switchName: Text { Text(string: "Receive email notifications every week", language: "en") }
    override var fieldName: Text { Text(string: "Enter your user name", language: "en") }
    override var saveTitle: Text { Text(string: "Save all of your changes", language: "en") }
    override var savedMessage: Text { Text(string: "Your changes have been saved.", language: "en") }
}
