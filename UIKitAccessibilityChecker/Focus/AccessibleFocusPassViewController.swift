import UIKit

/// FOCUS INDICATOR — Pass tier.
///
/// Every control's focus ring is easy to see (3:1 or better against the page and the control's
/// own fill) and is more than a colour: a heavy border, or a shadow. Nothing is reported.
///
/// Each ring is written as the colour a control takes in `didUpdateFocus` while it is the
/// focused view, so the scan judges it from the source: a ring that is not tied to focus is not
/// a focus indicator.
///
/// Elements covered (3) — none is a defect:
///   1. Dark 2pt ring          — #1A1A1A, 17:1
///   2. Blue 3pt ring          — #0B5FA5, 6.6:1
///   3. Dark hairline + shadow — 1pt #1A1A1A, with a shadow as a second cue

final class AccessibleFocusPassViewController: FocusDemoViewController {

    override var screenTitle: String { "Focus (Pass)" }

    override func build() {
        let darkHeavyRing = DarkHeavyRing(type: .custom).srcLine()
        place(darkHeavyRing, title: "Save changes")
        let blueHeavyRing = BlueHeavyRing(type: .custom).srcLine()
        place(blueHeavyRing, title: "Continue")
        let darkHairlineShadowRing = DarkHairlineShadowRing(type: .custom).srcLine()
        place(darkHairlineShadowRing, title: "Add to cart")
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

/// Draws its ring only while it has keyboard focus.
private final class DarkHairlineShadowRing: UIButton {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if context.nextFocusedView === self {
            layer.borderColor = UIColor(hex: "#1A1A1A").cgColor
            layer.borderWidth = 1
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.4
            layer.shadowRadius = 4
        } else {
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        }
    }
}
