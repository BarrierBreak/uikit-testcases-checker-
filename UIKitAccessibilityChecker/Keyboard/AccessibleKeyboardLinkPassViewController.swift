import UIKit

/// KEYBOARD LINKS — Pass tier.
///
/// Every link can be reached with Tab and followed with Space or Return.
///
/// Elements covered (2) — nothing is reported:
///   1. "Terms of service"  — UIButton with the link trait
///   2. "Privacy policy"    — custom view, focusable, overrides accessibilityActivate
final class AccessibleKeyboardLinkPassViewController: KeyboardLinkDemoViewController {

    override var screenTitle: String { "Keyboard Links (Pass)" }

    override var items: [Item] {
        [
            Item(title: "Terms of service", kind: .nativeLink),
            Item(title: "Privacy policy", kind: .operableCustomLink),
        ]
    }
}
