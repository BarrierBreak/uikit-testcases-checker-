//
//  AccessibleButtonDisabledFailViewController.swift
//
//  FAIL examples: Button disabled state (UIKit) — BB40079 "Disabled state of button not defined"
//  Each button LOOKS disabled, but its disabled state is not exposed natively
//  to assistive technology (no `.notEnabled` trait), so VoiceOver does not
//  announce "Dimmed". Some of them can also still be activated.
//
//  WCAG: 4.1.2 Name, Role, Value
//  Expected (pass) behaviour for comparison: `button.isEnabled = false`
//  -> VoiceOver: "<Name>, Dimmed, Button", double-tap does nothing.
//
//  Elements covered (5) — every one is BB40079 Fail:
//    1. Submit   — styled grey only (grey on grey, under 3:1), still enabled
//    2. Save     — isEnabled = false, then accessibilityTraits = .button drops .notEnabled
//    3. Next     — isUserInteractionEnabled = false, alpha 0.5, still enabled
//    4. Continue — "disabled" written into the accessibilityLabel, still enabled
//    5. Pay now  — custom view with .button, styled disabled, no .notEnabled
//

import UIKit

final class AccessibleButtonDisabledFailViewController: DisabledStateDemoViewController {

    override var screenTitle: String { "Disabled State – Fail" }
    override var headerText: String { "Disabled button state – fail examples" }

    override func buildCases() {
        // 1. Button only LOOKS disabled. isEnabled is still true.
        let submit = makeDisabledLookingButton(title: "Submit")
        submit.addAction(UIAction { [weak self] _ in
            self?.report("Case 1 'Submit' was activated (should be disabled)")
        }, for: .touchUpInside)
        addCase("1. Styled grey only, still enabled", submit)

        // 2. isEnabled = false, but accessibilityTraits is then overwritten.
        let save = makeDisabledLookingButton(title: "Save")
        save.isEnabled = false
        save.accessibilityTraits = .button   // FAIL: drops .notEnabled
        addCase("2. Disabled, but traits overwritten", save)

        // 3. Only user interaction is disabled.
        let next = makeDisabledLookingButton(title: "Next")
        next.isUserInteractionEnabled = false   // FAIL: not the same as isEnabled = false
        next.alpha = 0.5
        next.addAction(UIAction { [weak self] _ in
            self?.report("Case 3 'Next' was activated")
        }, for: .touchUpInside)
        addCase("3. User interaction off, state not exposed", next)

        // 4. Disabled state is put into the label text instead of the trait.
        let proceed = makeDisabledLookingButton(title: "Continue")
        proceed.accessibilityLabel = "Continue disabled"   // FAIL: state as text, not trait
        proceed.addAction(UIAction { [weak self] _ in
            self?.report("Case 4 'Continue' was activated (should be disabled)")
        }, for: .touchUpInside)
        addCase("4. 'Disabled' written into the label", proceed)

        // 5. A custom UIView acting as a button, exposing only the .button trait.
        let pay = DisabledStateCustomButtonView(title: "Pay now", exposesState: false).srcLine()
        pay.isDisabledVisually = true
        pay.onTap = { [weak self] in self?.report("Case 5 'Pay now' was activated") }
        addCase("5. Custom view button without state", pay)
    }
}
