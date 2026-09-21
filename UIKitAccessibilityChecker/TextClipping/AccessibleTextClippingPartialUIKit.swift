import UIKit

/// TEXT CLIPPING — Partial tier. WCAG 1.4.4.
///
/// A realistic screen: most of the text fits, two pieces do not. The scan should report both
/// outcomes side by side — "Text is not getting clipped" (BB40030) for the labels that are
/// fine and "Text getting clipped" (BB40033) for the two that are not — which is what
/// distinguishes this tier from Pass and Fail.
///
/// Elements covered (5): 3 clean, 2 clipped.
///   1. Heading, fits                     — pass
///   2. Body copy, wraps freely           — pass
///   3. Price row, single line with room  — pass
///   4. Promo strapline, truncated        — FAIL
///   5. Disclaimer capped at one line     — FAIL
final class AccessibleTextClippingPartialViewController: UIViewController {

    private let headingLabel = UILabel().srcLine()
    private let bodyLabel = UILabel().srcLine()
    private let priceLabel = UILabel().srcLine()
    private let promoLabel = UILabel().srcLine()
    private let disclaimerLabel = UILabel().srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Text Clipping (Partial)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        // 1-3. Clean.
        configure(headingLabel, text: "Checkout", lines: 1,
                  frame: CGRect(x: 24, y: 24, width: 320, height: 32))
        configure(bodyLabel, text: "Review your items before you pay.", lines: 0,
                  frame: CGRect(x: 24, y: 72, width: 320, height: 60))
        configure(priceLabel, text: "Total £42.60", lines: 1,
                  frame: CGRect(x: 24, y: 148, width: 320, height: 28))

        // 4. Marketing copy dropped into a fixed-width slot — the usual way clipping reaches
        // production, because the string is longer in some locales than the one it was
        // designed against.
        configure(promoLabel, text: "Spend £50 today and get free next-day delivery on this order",
                  lines: 1, frame: CGRect(x: 24, y: 192, width: 150, height: 28))
        promoLabel.lineBreakMode = .byTruncatingTail

        // 5. Legal text capped to one line, which is exactly where nobody notices it is cut.
        configure(disclaimerLabel,
                  text: "Prices include VAT. Delivery charges are calculated at the next step.",
                  lines: 1, frame: CGRect(x: 24, y: 240, width: 200, height: 24))
        disclaimerLabel.lineBreakMode = .byTruncatingTail
    }

    private func configure(_ label: UILabel, text: String, lines: Int, frame: CGRect) {
        label.frame = frame
        label.text = text
        label.numberOfLines = lines
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        view.addSubview(label)
    }
}
