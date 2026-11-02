import UIKit

/// BUTTON DISABLED STATE — Partial tier for BB40079 "Disabled state of button not defined".
///
/// Elements covered (4):
///   1. Submit   — isEnabled = false (UIKit adds .notEnabled)                → no row
///   2. Save     — isEnabled = false, traits overwritten without .notEnabled  → BB40079 Fail
///   3. Pay now  — custom view, disabled look AND [.button, .notEnabled]      → no row
///   4. Next     — styled grey only, still enabled                            → BB40079 Fail
final class AccessibleButtonDisabledPartialViewController: DisabledStateDemoViewController {

    override var screenTitle: String { "Disabled State – Partial" }
    override var headerText: String { "Disabled button state – partial examples" }

    override func buildCases() {
        let submit = makeDisabledLookingButton(title: "Submit")
        submit.isEnabled = false
        addCase("1. isEnabled = false", submit)

        let save = makeDisabledLookingButton(title: "Save")
        save.isEnabled = false
        save.accessibilityTraits = .button
        addCase("2. Disabled, but traits overwritten", save)

        let pay = DisabledStateCustomButtonView(title: "Pay now", exposesState: true).srcLine()
        pay.isDisabledVisually = true
        addCase("3. Custom view button with .notEnabled", pay)

        let next = makeDisabledLookingButton(title: "Next")
        next.addAction(UIAction { [weak self] _ in self?.report("'Next' was activated") }, for: .touchUpInside)
        addCase("4. Styled grey only, still enabled", next)
    }
}
