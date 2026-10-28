import UIKit

/// AUTOCOMPLETE — Pass tier.
///
/// Elements covered (2) — none is a defect:
///   1. Email address — textContentType .emailAddress   → BB40092 Pass
///   2. Password      — textContentType .password       → BB40092 Pass
final class AccessibleAutocompletePassViewController: NewRuleScreen {

    override var screenTitle: String { "Autocomplete (Pass)" }

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
        field("Password", keyboard: .default, secure: true, content: .password, tag: 1)
    }
}
