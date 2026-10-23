import UIKit

/// FORM LABEL — Pass tier.
///
/// Both fields have a persistent visible label and an explicit accessible name, so the
/// placeholder is a hint rather than the only name. BB40034 reports only the failure, so this
/// screen produces no BB40034 row.
///
/// Elements covered (2) — neither is a defect:
///   1. Email      — label above the field, accessibilityLabel set
///   2. Full name  — label above the field, accessibilityLabel set
final class AccessibleFormLabelPassViewController: NewRuleScreen {

    override var screenTitle: String { "Form Label (Pass)" }

    override func build() {
        for (index, name) in ["Email", "Full name"].enumerated() {
            let label = UILabel()
            label.text = name
            place(label, height: 20, gap: 6)

            let field = UITextField().srcLine()
            field.tag = index
            field.borderStyle = .roundedRect
            field.placeholder = "Enter \(name.lowercased())"
            field.accessibilityLabel = name
            place(field, gap: 40)
        }
    }
}
