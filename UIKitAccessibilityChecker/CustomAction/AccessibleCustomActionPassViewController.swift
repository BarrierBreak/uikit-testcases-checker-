import UIKit

/// CUSTOM ACTION — Pass tier.
///
/// Four cards are driven by a complex gesture (swipe, drag, pinch, press and hold), and each
/// also exposes a custom action that does the same thing. Each reports BB40191 "Custom action
/// present for gesture".
///
/// Elements covered (4) — none is a defect:
///   1. Archive message  — swipe, with custom action    → BB40191 Pass
///   2. Move card        — drag, with custom action     → BB40191 Pass
///   3. Zoom photo       — pinch, with custom action    → BB40191 Pass
///   4. Show options     — press and hold, with custom action → BB40191 Pass
final class AccessibleCustomActionPassViewController: NewRuleScreen {

    override var screenTitle: String { "Custom Action (Pass)" }

    override func build() {
        let cards: [(String, Gesture)] = [("Archive message", .swipe), ("Move card", .pan),
                                          ("Zoom photo", .pinch), ("Show options", .longPress)]
        for (index, card) in cards.enumerated() {
            place(gestureCard(card.0, gesture: card.1, alternative: true, tag: index), height: 56, gap: 20)
        }
    }
}
