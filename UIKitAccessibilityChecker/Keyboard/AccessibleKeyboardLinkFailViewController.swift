import UIKit

/// KEYBOARD LINKS — Fail tier.
///
/// Every link is a plain view with the link trait and a tap gesture. One is skipped by Tab,
/// the other takes focus but a Select press has nothing to trigger. Each reports BB41067
/// "Link not keyboard operable".
///
/// Elements covered (2) — every one fails:
///   1. "Terms of service"  — cannot receive keyboard focus
///   2. "Help centre"       — focusable, but a Select press does nothing
final class AccessibleKeyboardLinkFailViewController: KeyboardLinkDemoViewController {

    override var screenTitle: String { "Keyboard Links (Fail)" }

    override var items: [Item] {
        [
            Item(title: "Terms of service", kind: .unreachableCustomLink),
            Item(title: "Help centre", kind: .inertCustomLink),
        ]
    }
}
