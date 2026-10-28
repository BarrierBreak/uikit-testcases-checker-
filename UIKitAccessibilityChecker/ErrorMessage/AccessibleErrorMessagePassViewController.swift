import UIKit

/// ERROR MESSAGE — Pass tier.
///
/// Every field has an error message under it, and each one is exposed to VoiceOver, so a
/// screen-reader user hears what went wrong. Nothing is reported for BB40095.
///
/// Elements covered (3) — none is a defect:
///   1. Email    — error label, exposed       → no row
///   2. Password — error label, exposed       → no row
///   3. Username — error label, exposed       → no row
final class AccessibleErrorMessagePassViewController: NewRuleScreen {

    override var screenTitle: String { "Error Message (Pass)" }


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
        place(card("Password is required", placeholder: "Password", how: .exposed, tag: 1), height: 76)
        place(card("Username must be at least 3 characters", placeholder: "Username", how: .exposed, tag: 2), height: 76)
    }
}
