import UIKit

/// FOCUS INDICATOR — Pass tier.
///
/// Every control's focus ring is easy to see (3:1 or better against the page and the control's
/// own fill) and is more than a colour: a heavy border, or a shadow. Nothing is reported.
///
/// Elements covered (3) — none is a defect:
///   1. Dark 2pt ring          — #1A1A1A, 17:1
///   2. Blue 3pt ring          — #0B5FA5, 6.6:1
///   3. Dark hairline + shadow — 1pt #1A1A1A, with a shadow as a second cue
final class AccessibleFocusPassViewController: FocusDemoViewController {

    override var screenTitle: String { "Focus (Pass)" }

    override var rings: [Ring] {
        [
            Ring(title: "Save changes", color: "#1A1A1A", width: 2),
            Ring(title: "Continue", color: "#0B5FA5", width: 3),
            Ring(title: "Add to cart", color: "#1A1A1A", width: 1, shadow: true),
        ]
    }
}
