import UIKit

/// KEYBOARD LINKS — Partial tier.
///
/// One link a keyboard can use, one it cannot.
///
/// Elements covered (2):
///   1. "Terms of service"  — UIButton with the link trait   → nothing
///   2. "Help centre"       — plain view, Tab skips it       → BB41067 Fail
final class AccessibleKeyboardLinkPartialViewController: KeyboardLinkDemoViewController {

    override var screenTitle: String { "Keyboard Links (Partial)" }

    override var items: [Item] {
        [
            Item(title: "Terms of service", kind: .nativeLink),
            Item(title: "Help centre", kind: .unreachableCustomLink),
        ]
    }
}
