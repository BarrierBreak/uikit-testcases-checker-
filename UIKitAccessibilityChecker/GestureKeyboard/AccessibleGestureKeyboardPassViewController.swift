import UIKit

/// GESTURE KEYBOARD — Pass tier.
///
/// Elements covered (2) — none is a defect:
///   1. Open inbox    — tap card whose class overrides accessibilityActivate()   → BB40072 Pass
///   2. Open settings — tap card with a custom action                            → BB40072 Pass
final class AccessibleGestureKeyboardPassViewController: NewRuleScreen {

    override var screenTitle: String { "Gesture Keyboard (Pass)" }

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
        card("Open inbox", how: .activate, tag: 0)
        card("Open settings", how: .customAction, tag: 1)
    }
}

/// A tappable card that can be operated without touch: `accessibilityActivate()` runs the same handler.
final class ActivatableCard: UIView {
    var handler: () -> Void = {}
    override func accessibilityActivate() -> Bool { handler(); return true }
}

/// A plain tappable card; operability comes from its custom action alone.
final class ActivatableCardPlain: UIView {}
