import UIKit

/// MOTION — Pass tier.
///
/// Two cards act on a shake, and each has an accessible button inside it that does the same
/// thing, so a user who cannot shake the phone loses nothing. Each reports BB40102
/// "Accessible alternative control is available for motion-based action".
///
/// Elements covered (2) — neither is a defect:
///   1. Undo card   — shake to undo, with an "Undo last change" button
///   2. Clear card  — shake to clear, with a "Clear the form" button
final class AccessibleMotionPassViewController: MotionDemoViewController {

    override var screenTitle: String { "Motion (Pass)" }

    override var cards: [Card] {
        [
            Card(prompt: "Shake your phone to undo the last change", alternative: "Undo last change"),
            Card(prompt: "Shake your phone to clear the form", alternative: "Clear the form"),
        ]
    }
}
