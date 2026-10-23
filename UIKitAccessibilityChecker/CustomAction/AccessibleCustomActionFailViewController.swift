import UIKit

/// CUSTOM ACTION — Fail tier.
///
/// The same four gesture-driven cards, none with a custom action, so a VoiceOver or Switch
/// Control user has no way to do what the gesture does. Each reports BB40190 "Complex gesture
/// has no accessibility alternative".
///
/// Elements covered (4) — every one fails:
///   1. Archive message  — swipe, no custom action          → BB40190 Fail
///   2. Move card        — drag, no custom action           → BB40190 Fail
///   3. Zoom photo       — pinch, no custom action          → BB40190 Fail
///   4. Show options     — press and hold, no custom action → BB40190 Fail
final class AccessibleCustomActionFailViewController: NewRuleScreen {

    override var screenTitle: String { "Custom Action (Fail)" }

    override func build() {
        let cards: [(String, Gesture)] = [("Archive message", .swipe), ("Move card", .pan),
                                          ("Zoom photo", .pinch), ("Show options", .longPress)]
        for (index, card) in cards.enumerated() {
            place(gestureCard(card.0, gesture: card.1, alternative: false, tag: index), height: 56, gap: 20)
        }
    }
}
