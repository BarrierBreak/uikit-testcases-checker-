import UIKit

/// FOCUS INDICATOR — Partial tier.
///
/// Some rings are fine and some are not.
///
/// Elements covered (4):
///   1. Dark 2pt ring       — #1A1A1A                                 → nothing
///   2. Light 2pt ring      — #CFCFCF, 1.5:1                          → BB40117 Fail
///   3. Dark hairline       — 1pt #1A1A1A, no second cue              → BB40119 Fail
///   4. Blue 3pt ring       — #0B5FA5                                 → nothing
final class AccessibleFocusPartialViewController: FocusDemoViewController {

    override var screenTitle: String { "Focus (Partial)" }

    override var rings: [Ring] {
        [
            Ring(title: "Save changes", color: "#1A1A1A", width: 2),
            Ring(title: "Continue", color: "#CFCFCF", width: 2),
            Ring(title: "Add to cart", color: "#1A1A1A", width: 1),
            Ring(title: "Checkout", color: "#0B5FA5", width: 3),
        ]
    }
}
