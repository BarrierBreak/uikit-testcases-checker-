import UIKit

/// CUSTOM ACTION — Partial tier.
///
/// Two gesture-driven cards offer a custom action and two do not.
///
/// Elements covered (4):
///   1. Archive message  — swipe, with custom action    → BB40191 Pass
///   2. Zoom photo       — pinch, with custom action    → BB40191 Pass
///   3. Move card        — drag, no custom action       → BB40190 Fail
///   4. Show options     — press and hold, no custom action → BB40190 Fail
final class AccessibleCustomActionPartialViewController: NewRuleScreen {

    override var screenTitle: String { "Custom Action (Partial)" }

    override func build() {
        let cards: [(String, Gesture, Bool)] = [("Archive message", .swipe, true), ("Zoom photo", .pinch, true),
                                                ("Move card", .pan, false), ("Show options", .longPress, false)]
        for (index, card) in cards.enumerated() {
            place(gestureCard(card.0, gesture: card.1, alternative: card.2, tag: index), height: 56, gap: 20)
        }
    }
}
