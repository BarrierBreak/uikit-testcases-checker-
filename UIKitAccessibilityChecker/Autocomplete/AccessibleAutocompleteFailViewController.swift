import UIKit

/// AUTOCOMPLETE — Fail tier.
///
/// Elements covered (2) — every one is a defect:
///   1. Email address — email keyboard, no textContentType   → BB40091 Fail
///   2. Phone number  — phone keyboard, no textContentType   → BB40091 Fail
final class AccessibleAutocompleteFailViewController: NewRuleScreen {

    override var screenTitle: String { "Autocomplete (Fail)" }

    private func field(_ placeholder: String, keyboard: UIKeyboardType, secure: Bool = false,
                       content: UITextContentType?, tag: Int) {
        let field = UITextField().srcLine()
        field.tag = tag
        field.placeholder = placeholder
        field.accessibilityLabel = placeholder
        field.borderStyle = .roundedRect
        field.keyboardType = keyboard
        field.isSecureTextEntry = secure
        field.textContentType = content
        place(field)
    }

    override func build() {
        field("Email address", keyboard: .emailAddress, content: nil, tag: 0)
        field("Phone number", keyboard: .phonePad, content: nil, tag: 1)
    }
}
