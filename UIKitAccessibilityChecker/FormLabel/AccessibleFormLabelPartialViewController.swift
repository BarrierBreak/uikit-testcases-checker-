import UIKit

/// FORM LABEL — Partial tier.
///
/// One field is labelled properly; the other is a bare placeholder.
///
/// Elements covered (2):
///   1. Email       — label above the field, accessibilityLabel set   → no row
///   2. Promo code  — placeholder only, no label anywhere near it      → BB40034 Fail
final class AccessibleFormLabelPartialViewController: NewRuleScreen {

    override var screenTitle: String { "Form Label (Partial)" }

    override func build() {
        let label = UILabel()
        label.text = "Email"
        place(label, height: 20, gap: 6)

        let email = UITextField().srcLine()
        email.borderStyle = .roundedRect
        email.placeholder = "Enter email"
        email.accessibilityLabel = "Email"
        place(email, gap: 140)

        let promo = UITextField().srcLine()
        promo.borderStyle = .roundedRect
        promo.placeholder = "Promo code"
        place(promo)
    }
}
