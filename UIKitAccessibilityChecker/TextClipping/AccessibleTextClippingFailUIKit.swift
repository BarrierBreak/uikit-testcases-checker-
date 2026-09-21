import UIKit

/// TEXT CLIPPING — Fail tier. WCAG 1.4.4.
///
/// Every label here loses part of its text, so all of them report "Text getting clipped"
/// (BB40033). Each one fails for a different reason, because the fixes differ.
///
/// As on the Pass tier, every label opts into Dynamic Type so that clipping is the only
/// defect on the screen.
///
/// Elements covered (5):
///   1. Single line truncated at the tail — the classic "…" case
///   2. Single line hard-cut with .byClipping
///   3. Multi-line text in a box one line high
///   4. numberOfLines = 2 in a frame one line high
///   5. Text view whose content overflows its bounds
final class AccessibleTextClippingFailViewController: UIViewController {

    private let truncatedLabel = UILabel().srcLine()
    private let hardClippedLabel = UILabel().srcLine()
    private let squashedLabel = UILabel().srcLine()
    private let lineLimitedLabel = UILabel().srcLine()
    private let overflowingTextView = UITextView().srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Text Clipping (Fail)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        // 1. Far more text than 140pt can hold on one line, truncated with an ellipsis.
        configure(truncatedLabel,
                  text: "Estimated delivery Tuesday 14 March between 9am and 6pm",
                  lines: 1, frame: CGRect(x: 24, y: 24, width: 140, height: 28))
        truncatedLabel.lineBreakMode = .byTruncatingTail

        // 2. The same shape but cut off mid-glyph — no ellipsis to hint anything is missing,
        // which is the worse version for a reader.
        configure(hardClippedLabel,
                  text: "Payment method ending 4417 expires next month",
                  lines: 1, frame: CGRect(x: 24, y: 72, width: 140, height: 28))
        hardClippedLabel.lineBreakMode = .byClipping

        // 3. Wrapping text in a frame one line high. The remaining lines are simply not drawn.
        configure(squashedLabel,
                  text: "Your parcel is being held at the depot because nobody was home when the courier called.",
                  lines: 0, frame: CGRect(x: 24, y: 120, width: 300, height: 20))

        // 4. A hard two-line cap on copy that needs about four.
        configure(lineLimitedLabel,
                  text: "Refunds are issued to the original payment method and can take up to ten working days to appear, depending on your bank.",
                  lines: 2, frame: CGRect(x: 24, y: 168, width: 300, height: 20))

        // 5. A text view holding far more content than its 44pt bounds can show.
        //
        // Scrolling is deliberately left ON. With isScrollEnabled = false a UITextView sizes
        // its contentSize to its text, so contentSize.height never exceeds bounds.height and
        // the overflow check can never fire — the text would be visually cut but the scan
        // would call it clean.
        overflowingTextView.frame = CGRect(x: 24, y: 232, width: 300, height: 44)
        overflowingTextView.font = UIFont.preferredFont(forTextStyle: .body)
        overflowingTextView.adjustsFontForContentSizeCategory = true
        overflowingTextView.isEditable = false
        overflowingTextView.text = "These terms describe how we handle returns, exchanges and refunds, and what happens if an item arrives damaged or if the wrong item was sent to you."
        overflowingTextView.accessibilityLabel = "Returns policy"
        view.addSubview(overflowingTextView)
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
