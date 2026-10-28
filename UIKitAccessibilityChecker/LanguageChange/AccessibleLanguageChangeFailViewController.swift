import UIKit

/// LANGUAGE CHANGE — Fail tier.
///
/// Elements covered (2) — every one is a defect:
///   1. English sentence tagged "fr" (wrong tag)                          → BB40107 Fail
///   2. English and French sentence in one label, nothing tagged          → BB40107 Fail
final class AccessibleLanguageChangeFailViewController: NewRuleScreen {

    override var screenTitle: String { "Language Change (Fail)" }

    private static let english = "Thank you for visiting our shop today, we are open every day of the week."
    private static let french = "Merci beaucoup pour votre visite aujourd'hui, nous sommes ouverts tous les jours de la semaine."

    /// A multi-line label showing `text`, with the speech language of each run given by `runs`
    /// (a nil language leaves the run untagged).
    private func label(_ runs: [(String, String?)], tag: Int) {
        let text = NSMutableAttributedString()
        for (index, run) in runs.enumerated() {
            var attributes: [NSAttributedString.Key: Any] = [:]
            if let language = run.1 { attributes[.accessibilitySpeechLanguage] = language }
            text.append(NSAttributedString(string: (index > 0 ? " " : "") + run.0, attributes: attributes))
        }
        let label = UILabel().srcLine()
        label.tag = tag
        label.numberOfLines = 0
        label.attributedText = text
        place(label, height: 90, gap: 24)
    }

    override func build() {
        label([(Self.english, "fr")], tag: 0)
        label([(Self.english, nil), (Self.french, nil)], tag: 1)
    }
}
