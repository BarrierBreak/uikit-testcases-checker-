import UIKit

/// FOCUS ORDER — Pass tier.
///
/// Elements covered (1) — none is a defect:
///   1. First, Second, Third — presented in layout order   → BB40054 Pass
final class AccessibleFocusOrderPassViewController: NewRuleScreen {

    override var screenTitle: String { "Focus Order (Pass)" }

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
    }
}
