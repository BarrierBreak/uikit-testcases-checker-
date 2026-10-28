import UIKit

/// ERROR MESSAGE — Partial tier.
///
/// Two errors are announced and two are not.
///
/// Elements covered (4):
///   1. Email    — error label, exposed                                 → no row
///   2. Password — error label with isAccessibilityElement = false      → BB40095 Fail
///   3. Username — error label, exposed                                 → no row
///   4. Card number — error label inside a view that hides its subtree  → BB40095 Fail
final class AccessibleErrorMessagePartialViewController: NewRuleScreen {

    override var screenTitle: String { "Error Message (Partial)" }


    /// A form row: a field and the error text under it. `how` decides how the error is exposed.
    enum Exposure { case exposed, notAnElement, hiddenByParent }

    private func card(_ text: String, placeholder: String, how: Exposure, tag: Int) -> UIView {
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
        error.textColor = .systemRed
        error.frame = CGRect(x: 0, y: 48, width: 300, height: 24)
        switch how {
        case .exposed:
            error.isAccessibilityElement = true
            card.addSubview(error)
        case .notAnElement:
            error.isAccessibilityElement = false
            card.addSubview(error)
        case .hiddenByParent:
            let wrapper = UIView(frame: CGRect(x: 0, y: 48, width: 300, height: 24))
            wrapper.accessibilityElementsHidden = true
            error.frame = wrapper.bounds
            wrapper.addSubview(error)
            card.addSubview(wrapper)
        }
        return card
    }

    override func build() {
        place(card("Error: enter a valid email address", placeholder: "Email", how: .exposed, tag: 0), height: 76)
        place(card("Password is required", placeholder: "Password", how: .notAnElement, tag: 1), height: 76)
        place(card("Username must be at least 3 characters", placeholder: "Username", how: .exposed, tag: 2), height: 76)
        place(card("Card number is incorrect", placeholder: "Card number", how: .hiddenByParent, tag: 3), height: 76)
    }
}
