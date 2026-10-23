import UIKit

/// STATE TRAIT — Partial tier.
///
/// Two controls state their condition correctly and two do not.
///
/// Elements covered (3):
///   1. Place order    — disabled UIButton that carries .notEnabled   → BB40277 Pass
///   2. Bold           — selected UIButton without .selected          → no BB40277
///   3. Share          — disabled UIButton with .notEnabled dropped   → BB40079 Fail (Button rule)
final class AccessibleStateTraitPartialViewController: NewRuleScreen {

    override var screenTitle: String { "State Trait (Partial)" }

    override func build() {
        let order = UIButton(type: .system).srcLine()
        order.setTitle("Place order", for: .normal)
        order.isEnabled = false
        order.accessibilityTraits = [.button, .notEnabled]
        place(order)

        let bold = UIButton(type: .system).srcLine()
        bold.setTitle("Bold", for: .normal)
        bold.isSelected = true
        bold.accessibilityTraits = [.button]
        place(bold)

        let share = UIButton(type: .system).srcLine()
        share.setTitle("Share", for: .normal)
        share.isEnabled = false
        share.accessibilityTraits = [.button]
        place(share)
    }
}
