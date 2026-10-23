import UIKit

/// TOUCH EVENT — Partial tier.
///
/// Two actions run on release and two run on touch down.
///
/// Elements covered (4):
///   1. Save changes   — UIButton, action on .touchUpInside         → BB40137 Pass
///   2. Open details   — view with a tap recognizer                 → BB40137 Pass
///   3. Delete         — UIButton, action on .touchDown             → BB40136 Fail
///   4. Buy now        — view with a press recognizer of duration 0 → BB40136 Fail
final class AccessibleTouchEventPartialViewController: NewRuleScreen {

    override var screenTitle: String { "Touch Event (Partial)" }

    override func build() {
        let save = UIButton(type: .system).srcLine()
        save.setTitle("Save changes", for: .normal)
        save.addTarget(self, action: #selector(activate), for: .touchUpInside)
        place(save)

        let details = UIView().srcLine()
        details.backgroundColor = .secondarySystemBackground
        details.layer.cornerRadius = 12
        details.isAccessibilityElement = true
        details.accessibilityLabel = "Open details"
        details.accessibilityTraits = .button
        details.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        place(details, height: 56)

        let delete = UIButton(type: .system).srcLine()
        delete.setTitle("Delete", for: .normal)
        delete.addTarget(self, action: #selector(activate), for: .touchDown)
        place(delete)

        let buy = UIView().srcLine()
        buy.backgroundColor = .secondarySystemBackground
        buy.layer.cornerRadius = 12
        buy.isAccessibilityElement = true
        buy.accessibilityLabel = "Buy now"
        buy.accessibilityTraits = .button
        let press = UILongPressGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        press.minimumPressDuration = 0
        buy.addGestureRecognizer(press)
        place(buy, height: 56)
    }
}
