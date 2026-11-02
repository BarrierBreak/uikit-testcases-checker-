import UIKit

/// BUTTON DISABLED STATE — Pass tier for BB40079 "Disabled state of button not defined".
///
/// Every disabled button tells VoiceOver it is disabled ("Dimmed").
///
/// Elements covered (4) — none is reported:
///   1. Submit   — isEnabled = false (UIKit adds .notEnabled)                 → no row
///   2. Save     — isEnabled = false, traits set WITH .notEnabled              → no row
///   3. Pay now  — custom view, disabled look AND [.button, .notEnabled]       → no row
///   4. Continue — enabled, normal look                                        → no row
final class AccessibleButtonDisabledPassViewController: DisabledStateDemoViewController {

    override var screenTitle: String { "Disabled State – Pass" }
    override var headerText: String { "Disabled button state – pass examples" }

    override func buildCases() {
        let submit = makeDisabledLookingButton(title: "Submit")
        submit.isEnabled = false
        addCase("1. isEnabled = false", submit)

        let save = makeDisabledLookingButton(title: "Save")
        save.isEnabled = false
        save.accessibilityTraits = [.button, .notEnabled]
        addCase("2. Disabled, traits keep .notEnabled", save)

        let pay = DisabledStateCustomButtonView(title: "Pay now", exposesState: true).srcLine()
        pay.isDisabledVisually = true
        addCase("3. Custom view button with .notEnabled", pay)

        let proceed = makeButton(title: "Continue")
        proceed.addAction(UIAction { [weak self] _ in self?.report("'Continue' was activated") }, for: .touchUpInside)
        addCase("4. Enabled button", proceed)
    }
}
