import UIKit

/// STATE TRAIT — Pass tier.
///
/// Two controls whose accessibility state matches their real state. Each reports BB40277
/// "Accessibility state trait correctly reflects element's actual state".
///
/// Elements covered (2) — none is a defect:
///   1. Place order    — disabled UIButton that carries .notEnabled   → BB40277 Pass
///   2. Bold           — selected UIButton that carries .selected     → BB40277 Pass
final class AccessibleStateTraitPassViewController: NewRuleScreen {

    override var screenTitle: String { "State Trait (Pass)" }

    override func build() {
        let order = UIButton(type: .system).srcLine()
        order.setTitle("Place order", for: .normal)
        order.isEnabled = false
        order.accessibilityTraits = [.button, .notEnabled]
        place(order)

        let bold = UIButton(type: .system).srcLine()
        bold.setTitle("Bold", for: .normal)
        bold.isSelected = true
        bold.accessibilityTraits = [.button, .selected]
        place(bold)
    }
}
