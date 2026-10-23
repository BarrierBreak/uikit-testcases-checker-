import UIKit

/// TOUCH EVENT — Pass tier.
///
/// Every action runs when the finger is lifted, so a person who touches the wrong control can
/// slide away and cancel. Each reports BB40137 "Action fires on touch up, allowing
/// cancellation".
///
/// Elements covered (3) — none is a defect:
///   1. Save changes   — UIButton, action on .touchUpInside      → BB40137 Pass
///   2. Send           — UIButton, action on .touchUpInside      → BB40137 Pass
///   3. Open details   — view with a tap recognizer (fires on end) → BB40137 Pass
final class AccessibleTouchEventPassViewController: NewRuleScreen {

    override var screenTitle: String { "Touch Event (Pass)" }

    override func build() {
        for (index, title) in ["Save changes", "Send"].enumerated() {
            let button = UIButton(type: .system).srcLine()
            button.tag = index
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(activate), for: .touchUpInside)
            place(button)
        }

        let card = UIView().srcLine()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.isAccessibilityElement = true
        card.accessibilityLabel = "Open details"
        card.accessibilityTraits = .button
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        place(card, height: 56)
    }
}
