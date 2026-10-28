import UIKit

/// FOCUS INDICATOR — Partial tier.
///
/// Some rings are fine and some are not.
///
/// Each ring is written as the colour a control takes in `didUpdateFocus` while it is the
/// focused view, so the scan judges it from the source: a ring that is not tied to focus is not
/// a focus indicator.
///
/// Elements covered (4):
///   1. Dark 2pt ring       — #1A1A1A                                 → nothing
///   2. Light 2pt ring      — #CFCFCF, 1.5:1                          → BB40117 Fail
///   3. Dark hairline       — 1pt #1A1A1A, no second cue              → BB40119 Fail
///   4. Blue 3pt ring       — #0B5FA5                                 → nothing

final class AccessibleFocusPartialViewController: FocusDemoViewController {

    override var screenTitle: String { "Focus (Partial)" }

    override func build() {
        let darkHeavyRing = DarkHeavyRing(type: .custom).srcLine()
        place(darkHeavyRing, title: "Save changes")
        let lightHeavyRing = LightHeavyRing(type: .custom).srcLine()
        place(lightHeavyRing, title: "Continue")
        let darkHairlineRing = DarkHairlineRing(type: .custom).srcLine()
        place(darkHairlineRing, title: "Add to cart")
        let blueHeavyRing = BlueHeavyRing(type: .custom).srcLine()
        place(blueHeavyRing, title: "Checkout")
    }
}

/// Draws its ring only while it has keyboard focus.
private final class DarkHeavyRing: UIButton {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if context.nextFocusedView === self {
            layer.borderColor = UIColor(hex: "#1A1A1A").cgColor
            layer.borderWidth = 2
        } else {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        }
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
private final class BlueHeavyRing: UIButton {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if context.nextFocusedView === self {
            layer.borderColor = UIColor(hex: "#0B5FA5").cgColor
            layer.borderWidth = 3
        } else {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        }
    }
}
