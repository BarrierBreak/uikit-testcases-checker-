import UIKit

/// BUTTON — Partial tier.
///
/// Two buttons are correct, one cannot be pressed and one does not say it is disabled.
///
/// Elements covered (4):
///   1. Save changes   — enabled, interactive button                  → no row
///   2. Place order    — disabled button that carries .notEnabled     → no row
///   3. Archive        — user interaction off                         → BB40001 Validate
///   4. Share          — disabled, .notEnabled dropped                → BB40079 Fail
final class AccessibleButtonPartialViewController: NewRuleScreen {

    override var screenTitle: String { "Button (Partial)" }

    override func build() {
        let save = UIButton(type: .system).srcLine()
        save.setTitle("Save changes", for: .normal)
        place(save)

        let order = UIButton(type: .system).srcLine()
        order.setTitle("Place order", for: .normal)
        order.isEnabled = false
        order.accessibilityTraits = [.button, .notEnabled]
        place(order)

        let archive = UIButton(type: .system).srcLine()
        archive.setTitle("Archive", for: .normal)
        archive.isUserInteractionEnabled = false
        place(archive)

        let share = UIButton(type: .system).srcLine()
        share.setTitle("Share", for: .normal)
        share.isEnabled = false
        share.accessibilityTraits = [.button]
        place(share)
    }
}
