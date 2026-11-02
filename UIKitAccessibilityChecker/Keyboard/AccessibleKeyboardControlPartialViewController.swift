import UIKit

/// KEYBOARD CONTROLS — Partial tier for BB40066 "Interactive control cannot receive keyboard focus".
///
/// The verdict is read live from the focus engine (`canBecomeFocused`), so it follows the code.
///
/// Elements covered (2):
///   1. Volume slider — stock UISlider, focusable                               → no row
///   2. Star rating   — custom .adjustable view that does not override
///                      canBecomeFocused, so a plain UIView's false applies       → BB40066 Fail
final class AccessibleKeyboardControlPartialViewController: NewRuleScreen {

    override var screenTitle: String { "Keyboard Control (Partial)" }

    override func build() {
        let slider = UISlider().srcLine()
        slider.accessibilityLabel = "Volume"
        place(slider)

        place(KeyboardRatingView(focusable: false).srcLine())
    }
}
