import UIKit

/// ERROR SUGGESTION — Fail tier.
///
/// No error both reaches VoiceOver and says how to fix it. BB40097 is a Pass-only rule, so
/// this screen produces no BB40097 row at all.
///
/// Elements covered (3) — every one is a defect:
///   1. Password error — "Password is required" (no fix)                       → no BB40097 row
///   2. Card error     — "Card number is incorrect" (no fix)                   → no BB40097 row
///   3. Email error    — suggests a fix but is not an accessibility element    → BB40095 Fail, no BB40097 row
final class AccessibleErrorSuggestionFailViewController: NewRuleScreen {

    override var screenTitle: String { "Error Suggestion (Fail)" }

    /// A form row: a field and the error text under it. With `exposed` false the error is
    /// not an accessibility element, so a screen reader never reaches it.
    private func card(_ text: String, placeholder: String, exposed: Bool = true, tag: Int) -> UIView {
        let card = UIView()
        card.tag = tag
        let field = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.accessibilityLabel = placeholder
        card.addSubview(field)

        let error = UILabel().srcLine()
        error.tag = tag
        error.text = text
        error.numberOfLines = 2
        error.font = .preferredFont(forTextStyle: .footnote)
        error.textColor = .systemRed
        error.frame = CGRect(x: 0, y: 48, width: 340, height: 40)
        error.isAccessibilityElement = exposed
        card.addSubview(error)
        return card
    }

    override func build() {
        place(card("Password is required", placeholder: "Password", tag: 0), height: 92)
        place(card("Card number is incorrect", placeholder: "Card number", tag: 1), height: 92)
        place(card("Invalid email address. Please check for a typo.", placeholder: "Email", exposed: false, tag: 2), height: 92)
    }
}
