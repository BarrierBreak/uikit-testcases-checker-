import UIKit

/// A `UIColorWell` whose accessible name the app actually controls.
///
/// `UIColorWell` supplies its own accessibility label — always "Color" — and discards
/// anything assigned to `accessibilityLabel` or to `title`. Both were measured: the Pass
/// screen set `favoriteColorWell.accessibilityLabel = "Favorite color"` and the control
/// still read back as "Color", and setting `title` changed nothing either. That leaves a
/// colour well impossible to name correctly *and* impossible to leave genuinely nameless,
/// so the Fail screen's unnamed well looked named and the Pass screen's named well looked
/// generic — the opposite of what each screen is there to demonstrate.
///
/// Overriding the getter is the one place the system label can be replaced. Assigning
/// `accessibilityLabel` now behaves the way it does on every other control, and leaving it
/// unset leaves the control with no accessible name at all.
///
/// This mirrors the SwiftUI screens, where the same defect is worked around with
/// `.accessibilityElement(children: .combine)` before `.accessibilityLabel(_:)`.
final class NamedColorWell: UIColorWell {

    private var providedLabel: String?

    override var accessibilityLabel: String? {
        get { providedLabel }
        set { providedLabel = newValue }
    }
}
