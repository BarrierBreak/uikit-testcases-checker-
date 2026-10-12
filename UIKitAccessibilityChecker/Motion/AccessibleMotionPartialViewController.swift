import UIKit

/// MOTION — Partial tier.
///
/// Two cards act on a shake. One has an accessible alternative and one does not.
///
/// Elements covered (2):
///   1. Undo card   — shake to undo, with an "Undo last change" button   → BB40102 Pass
///   2. Clear card  — shake to clear, nothing else on the card           → BB40052 Fail
final class AccessibleMotionPartialViewController: MotionDemoViewController {

    override var screenTitle: String { "Motion (Partial)" }

    override var cards: [Card] {
        [
            Card(prompt: "Shake your phone to undo the last change", alternative: "Undo last change"),
            Card(prompt: "Shake your phone to clear the form", alternative: nil),
        ]
    }
}
