import UIKit

/// GESTURE KEYBOARD — Fail tier.
///
/// Elements covered (2) — every one is a defect:
///   1. Open inbox    — tap recognizer only, no activate, no custom action   → BB40071 Fail
///   2. Open settings — tap recognizer only, no activate, no custom action   → BB40071 Fail
final class AccessibleGestureKeyboardFailViewController: NewRuleScreen {

    override var screenTitle: String { "Gesture Keyboard (Fail)" }

    /// A card driven by a tap recognizer. `how` decides whether it can be operated without touch.
    enum Operability { case activate, customAction, none }

    private func card(_ name: String, how: Operability, tag: Int) {
        let card: UIView
        switch how {
        case .activate:
            let activatable = ActivatableCard().srcLine()
            activatable.handler = { [weak self] in self?.activate() }
            card = activatable
        case .customAction:
            let custom = ActivatableCardPlain().srcLine()
            custom.accessibilityCustomActions = [
                UIAccessibilityCustomAction(name: "Open \(name)") { _ in true }
            ]
            card = custom
        case .none:
            card = UIView().srcLine()
        }
        card.tag = tag
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.isAccessibilityElement = true
        card.accessibilityLabel = name
        card.accessibilityTraits = .button
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        place(card, height: 80, gap: 24)
    }

    override func build() {
        card("Open inbox", how: .none, tag: 0)
        card("Open settings", how: .none, tag: 1)
    }
}
