import UIKit

/// TOUCH EVENT — Fail tier.
///
/// Every action runs the moment the finger lands, so a slip cannot be undone. Each reports
/// BB40136 "Action fires on touch down instead of touch up".
///
/// Elements covered (3) — every one fails:
///   1. Delete         — UIButton, action on .touchDown                    → BB40136 Fail
///   2. Send           — UIButton, action on .touchDown                    → BB40136 Fail
///   3. Buy now        — view with a press recognizer of duration 0        → BB40136 Fail
final class AccessibleTouchEventFailViewController: NewRuleScreen {

    override var screenTitle: String { "Touch Event (Fail)" }

    override func build() {
        for (index, title) in ["Delete", "Send"].enumerated() {
            let button = UIButton(type: .system).srcLine()
            button.tag = index
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(activate), for: .touchDown)
            place(button)
        }

        let card = UIView().srcLine()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.isAccessibilityElement = true
        card.accessibilityLabel = "Buy now"
        card.accessibilityTraits = .button
        let press = UILongPressGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        press.minimumPressDuration = 0
        card.addGestureRecognizer(press)
        place(card, height: 56)
    }
}
