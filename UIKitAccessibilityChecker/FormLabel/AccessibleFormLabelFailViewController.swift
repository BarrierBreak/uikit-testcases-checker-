import UIKit

/// FORM LABEL — Fail tier.
///
/// Both fields have a placeholder and nothing else: no visible label near them and no
/// accessibility label. VoiceOver falls back to the placeholder, which disappears as soon as
/// the person starts typing. Each reports BB40034 "Placeholder text used as the only accessible
/// name".
///
/// Elements covered (2) — every one fails:
///   1. Search        — placeholder only   → BB40034 Fail
///   2. Promo code    — placeholder only   → BB40034 Fail
final class AccessibleFormLabelFailViewController: NewRuleScreen {

    override var screenTitle: String { "Form Label (Fail)" }

    override func build() {
        for (index, placeholder) in ["Search", "Promo code"].enumerated() {
            let field = UITextField().srcLine()
            field.tag = index
            field.borderStyle = .roundedRect
            field.placeholder = placeholder
            place(field, gap: 120)
        }
    }
}
