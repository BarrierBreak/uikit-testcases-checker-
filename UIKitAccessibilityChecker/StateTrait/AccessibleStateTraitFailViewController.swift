import UIKit

/// STATE TRAIT — Fail tier.
///
/// Two controls whose accessibility state disagrees with their real state. BB40277 is a Pass
/// rule, so nothing here reports it; the disagreement is reported by the State and Button rules.
///
/// Elements covered (2) — none reports BB40277:
///   1. Place order    — disabled UIButton with .notEnabled dropped   → BB40079 Fail (Button rule)
///   2. Bold           — selected UIButton without .selected          → no BB40277
final class AccessibleStateTraitFailViewController: NewRuleScreen {

    override var screenTitle: String { "State Trait (Fail)" }

    override func build() {
        let order = UIButton(type: .system).srcLine()
        order.setTitle("Place order", for: .normal)
        order.isEnabled = false
        order.accessibilityTraits = [.button]
        place(order)

        let bold = UIButton(type: .system).srcLine()
        bold.setTitle("Bold", for: .normal)
        bold.isSelected = true
        bold.accessibilityTraits = [.button]
        place(bold)
    }
}
