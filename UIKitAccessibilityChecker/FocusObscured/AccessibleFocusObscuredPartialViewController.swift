import UIKit

/// FOCUS OBSCURED — Partial tier.
///
/// One control is covered, one has its banner beside it, and one is only brushed by the
/// banner, which hides under a third of it.
///
/// Elements covered (3):
///   1. Pay now    — banner covers the whole control        → BB40075 Validate
///   2. Promo code — banner sits below it, no overlap       → no row
///   3. Pay now    — banner covers 30% of the control       → no row
final class AccessibleFocusObscuredPartialViewController: NewRuleScreen {

    override var screenTitle: String { "Focus Obscured (Partial)" }


    /// A control with a banner drawn on top of it. `cover` is how much of the control's height
    /// the banner hides; 0 leaves the banner beside the control instead.
    private func row(_ index: Int, y: CGFloat, field: Bool, cover: CGFloat) {
        let control: UIView
        if field {
            let text = UITextField().srcLine()
            text.placeholder = "Promo code"
            text.accessibilityLabel = "Promo code"
            text.borderStyle = .roundedRect
            control = text
        } else {
            let button = UIButton(type: .system).srcLine()
            button.setTitle("Pay now", for: .normal)
            control = button
        }
        control.tag = index
        control.frame = CGRect(x: 24, y: y, width: 220, height: 44)
        view.addSubview(control)

        let banner = UIView()
        banner.backgroundColor = .systemYellow
        banner.isUserInteractionEnabled = true
        let message = UILabel(frame: CGRect(x: 8, y: 8, width: 200, height: 24))
        message.text = "Sale ends today"
        banner.addSubview(message)
        if cover > 0 {
            banner.frame = CGRect(x: 24, y: y + 44 - 44 * cover, width: 220, height: 44 * cover + 6)
        } else {
            banner.frame = CGRect(x: 24, y: y + 52, width: 220, height: 32)
        }
        view.addSubview(banner)
    }

    override func build() {
        row(0, y: 24, field: false, cover: 1)
        row(1, y: 120, field: true, cover: 0)
        row(2, y: 216, field: false, cover: 0.3)
    }
}
