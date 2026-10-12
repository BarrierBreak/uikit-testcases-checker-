import UIKit

/// MOTION — Fail tier.
///
/// Two cards act on a shake and neither offers a way in that works without one. Each reports
/// BB40052 "No On-Screen Alternative for Motion Action".
///
/// Elements covered (2) — both fail:
///   1. Refresh card  — shake to refresh, and nothing else on the card
///   2. Shuffle card  — shake to shuffle, with a Shuffle button that VoiceOver cannot reach
///                      (isAccessibilityElement = false), so it is not an alternative
final class AccessibleMotionFailViewController: MotionDemoViewController {

    override var screenTitle: String { "Motion (Fail)" }

    override var cards: [Card] {
        [
            Card(prompt: "Shake your phone to refresh the feed", alternative: nil),
            Card(prompt: "Shake your phone to shuffle the playlist", alternative: "Shuffle", exposed: false),
        ]
    }
}
