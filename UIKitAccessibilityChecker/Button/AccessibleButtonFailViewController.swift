import UIKit

/// BUTTON — Fail tier.
///
/// Every button here has a defect the Button rules report. (A button taken out of the
/// accessibility tree is reported by the Hidden rule, BB40046, which already covers the same
/// control, so it is not staged here.)
///
/// Elements covered (4) — every one is reported:
///   1. Save draft     — user interaction off: nothing can press it   → BB40001 Validate
///   2. Archive        — user interaction off: nothing can press it   → BB40001 Validate
///   3. Place order    — disabled, .notEnabled dropped                → BB40079 Fail
///   4. Share          — disabled, .notEnabled dropped                → BB40079 Fail
final class AccessibleButtonFailViewController: NewRuleScreen {

    override var screenTitle: String { "Button (Fail)" }

    override func build() {
        for (index, title) in ["Save draft", "Archive"].enumerated() {
            let button = UIButton(type: .system).srcLine()
            button.tag = index
            button.setTitle(title, for: .normal)
            button.isUserInteractionEnabled = false
            place(button)
        }

        for (index, title) in ["Place order", "Share"].enumerated() {
            let button = UIButton(type: .system).srcLine()
            button.tag = 10 + index
            button.setTitle(title, for: .normal)
            button.isEnabled = false
            button.accessibilityTraits = [.button]
            place(button)
        }
    }
}
