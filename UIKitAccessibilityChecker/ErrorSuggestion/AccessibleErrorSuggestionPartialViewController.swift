import UIKit

/// ERROR SUGGESTION — Partial tier.
///
/// One error says how to fix it and one only says what is wrong.
///
/// Elements covered (2):
///   1. Email error    — "… Please enter an address like …"  → BB40097 Pass
///   2. Password error — "Password is required" (no fix)     → no BB40097 row
final class AccessibleErrorSuggestionPartialViewController: NewRuleScreen {

    override var screenTitle: String { "Error Suggestion (Partial)" }

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
        place(card("Invalid email address. Please enter an address like name@example.com", placeholder: "Email", tag: 0), height: 92)
        place(card("Password is required", placeholder: "Password", tag: 1), height: 92)
    }
}
