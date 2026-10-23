import UIKit

/// FOCUS INDICATOR — Fail tier.
///
/// Every control's focus ring has one of the two defects, and one has both.
///
///   BB40117  "Insufficient color contrast for focus indicator"  — under 3:1
///   BB40119  "Color alone used to indicate focus"               — a hairline, no shadow
///
/// Elements covered (4) — every one fails:
///   1. Light 2pt ring       — #CFCFCF, 1.5:1                         → BB40117
///   2. Grey 2pt ring        — #A0A0A0, 2.6:1                         → BB40117
///   3. Dark hairline        — 1pt #1A1A1A: easy to see, but a line   → BB40119
///   4. Light hairline       — 1pt #CFCFCF: both defects              → BB40117 and BB40119
final class AccessibleFocusFailViewController: FocusDemoViewController {

    override var screenTitle: String { "Focus (Fail)" }

    override var rings: [Ring] {
        [
            Ring(title: "Save changes", color: "#CFCFCF", width: 2),
            Ring(title: "Continue", color: "#A0A0A0", width: 2),
            Ring(title: "Add to cart", color: "#1A1A1A", width: 1),
            Ring(title: "Checkout", color: "#CFCFCF", width: 1),
        ]
    }
}
