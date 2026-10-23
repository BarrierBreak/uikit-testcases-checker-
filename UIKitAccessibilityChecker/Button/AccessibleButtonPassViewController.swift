import UIKit

/// BUTTON — Pass tier.
///
/// Every button can be pressed, can be reached with VoiceOver, and says so when it is disabled.
/// The Button rules report nothing for a correct button, so this screen produces no BB40001,
/// BB40078 or BB40079 row.
///
/// Elements covered (3) — none is a defect:
///   1. Save changes   — enabled, interactive button
///   2. Continue       — enabled, interactive button
///   3. Place order    — disabled button that carries .notEnabled
final class AccessibleButtonPassViewController: NewRuleScreen {

    override var screenTitle: String { "Button (Pass)" }

    override func build() {
        for (index, title) in ["Save changes", "Continue"].enumerated() {
            let button = UIButton(type: .system).srcLine()
            button.tag = index
            button.setTitle(title, for: .normal)
            place(button)
        }

        let order = UIButton(type: .system).srcLine()
        order.setTitle("Place order", for: .normal)
        order.isEnabled = false
        order.accessibilityTraits = [.button, .notEnabled]
        place(order)
    }
}
