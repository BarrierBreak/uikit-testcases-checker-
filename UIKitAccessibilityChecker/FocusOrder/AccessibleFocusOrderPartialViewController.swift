import UIKit

/// FOCUS ORDER — Partial tier.
///
/// Elements covered (2):
///   1. First, Second, Third — presented in layout order        → BB40054 Pass
///   2. First, Second, Third — presented Third, Second, First   → BB40053 Validate
final class AccessibleFocusOrderPartialViewController: NewRuleScreen {

    override var screenTitle: String { "Focus Order (Partial)" }

    /// A container of three buttons stacked top to bottom. `reversed` presents them to
    /// VoiceOver last-first, against the layout.
    private func group(reversed: Bool, tag: Int) {
        let container = UIView().srcLine()
        container.tag = tag
        var buttons: [UIButton] = []
        for (index, name) in ["First", "Second", "Third"].enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(name, for: .normal)
            button.frame = CGRect(x: 0, y: CGFloat(index) * 56, width: 160, height: 44)
            container.addSubview(button)
            buttons.append(button)
        }
        container.accessibilityElements = reversed ? buttons.reversed() : buttons
        place(container, height: 156, width: 160, gap: 24)
    }

    override func build() {
        group(reversed: false, tag: 0)
        group(reversed: true, tag: 1)
    }
}
