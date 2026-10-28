import UIKit

/// AUTOCOMPLETE — Partial tier.
///
/// Elements covered (2):
///   1. Email address — textContentType .emailAddress          → BB40092 Pass
///   2. Phone number  — phone keyboard, no textContentType     → BB40091 Fail
final class AccessibleAutocompletePartialViewController: NewRuleScreen {

    override var screenTitle: String { "Autocomplete (Partial)" }

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
        field("Email address", keyboard: .emailAddress, content: .emailAddress, tag: 0)
        field("Phone number", keyboard: .phonePad, content: nil, tag: 1)
    }
}
