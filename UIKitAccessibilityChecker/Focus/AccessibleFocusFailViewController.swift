import UIKit

/// FOCUS INDICATOR — Fail tier.
///
/// Every control's focus ring has one of the two defects, and one has both.
///
///   BB40117  "Insufficient color contrast for focus indicator"  — under 3:1
///   BB40119  "Color alone used to indicate focus"               — a hairline, no shadow
///
/// Each ring is written as the colour a control takes in `didUpdateFocus` while it is the
/// focused view, so the scan judges it from the source: a ring that is not tied to focus is not
/// a focus indicator.
///
/// Elements covered (4) — every one fails:
///   1. Light 2pt ring       — #CFCFCF, 1.5:1                         → BB40117
///   2. Grey 2pt ring        — #A0A0A0, 2.6:1                         → BB40117
///   3. Dark hairline        — 1pt #1A1A1A: easy to see, but a line   → BB40119
///   4. Light hairline       — 1pt #CFCFCF: both defects              → BB40117 and BB40119

final class AccessibleFocusFailViewController: FocusDemoViewController {

    override var screenTitle: String { "Focus (Fail)" }

    override func build() {
        let lightHeavyRing = LightHeavyRing(type: .custom).srcLine()
        place(lightHeavyRing, title: "Save changes")
        let greyHeavyRing = GreyHeavyRing(type: .custom).srcLine()
        place(greyHeavyRing, title: "Continue")
        let darkHairlineRing = DarkHairlineRing(type: .custom).srcLine()
        place(darkHairlineRing, title: "Add to cart")
        let lightHairlineRing = LightHairlineRing(type: .custom).srcLine()
        place(lightHairlineRing, title: "Checkout")
    }
}

/// Draws its ring only while it has keyboard focus.
private final class LightHeavyRing: UIButton {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if context.nextFocusedView === self {
            layer.borderColor = UIColor(hex: "#CFCFCF").cgColor
            layer.borderWidth = 2
        } else {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        }
    }
}

/// Draws its ring only while it has keyboard focus.
private final class GreyHeavyRing: UIButton {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if context.nextFocusedView === self {
            layer.borderColor = UIColor(hex: "#A0A0A0").cgColor
            layer.borderWidth = 2
        } else {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        }
    }
}

/// Draws its ring only while it has keyboard focus.
private final class DarkHairlineRing: UIButton {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if context.nextFocusedView === self {
            layer.borderColor = UIColor(hex: "#1A1A1A").cgColor
            layer.borderWidth = 1
        } else {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        }
    }
}

/// Draws its ring only while it has keyboard focus.
private final class LightHairlineRing: UIButton {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if context.nextFocusedView === self {
            layer.borderColor = UIColor(hex: "#CFCFCF").cgColor
            layer.borderWidth = 1
        } else {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        }
    }
}
