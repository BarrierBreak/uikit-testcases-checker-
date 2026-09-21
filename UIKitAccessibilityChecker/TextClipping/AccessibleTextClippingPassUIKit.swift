import UIKit

/// TEXT CLIPPING — Pass tier. WCAG 1.4.4.
///
/// Every label here is free to grow with its content, so all of them report
/// "Text is not getting clipped" (BB40030) and none reports BB40033.
///
/// Every label also opts into Dynamic Type, which is deliberate: it keeps this screen about
/// clipping alone. A label with a fixed font would also draw a "Text fails to resize" row and
/// muddy which defect the tier is demonstrating.
///
/// Elements covered (5):
///   1. Single line, room to spare
///   2. Multi-line, numberOfLines = 0, sized to content
///   3. Long body text over several lines with a generous frame
///   4. Two-line label whose frame fits exactly two lines
///   5. Text view whose content fits its bounds
final class AccessibleTextClippingPassViewController: UIViewController {

    private let shortLabel = UILabel().srcLine()
    private let wrappingLabel = UILabel().srcLine()
    private let bodyLabel = UILabel().srcLine()
    private let twoLineLabel = UILabel().srcLine()
    private let notesTextView = UITextView().srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Text Clipping (Pass)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        // 1. Comfortably wider than its text.
        configure(shortLabel, text: "Order summary", lines: 1,
                  frame: CGRect(x: 24, y: 24, width: 320, height: 28))

        // 2. numberOfLines = 0 — the label takes as many lines as it needs.
        configure(wrappingLabel,
                  text: "Your order will arrive between Tuesday and Thursday next week.",
                  lines: 0, frame: CGRect(x: 24, y: 68, width: 320, height: 80))

        // 3. Long copy with a frame sized for it.
        configure(bodyLabel,
                  text: "Delivery times are estimates and can change if the weather is bad or if the courier is held up on an earlier stop.",
                  lines: 0, frame: CGRect(x: 24, y: 164, width: 320, height: 140))

        // 4. Two lines allowed, two lines needed — the boundary case that still fits.
        configure(twoLineLabel, text: "Contactless delivery is available on request",
                  lines: 2, frame: CGRect(x: 24, y: 320, width: 320, height: 56))

        // 5. A text view whose content height is under its bounds height.
        notesTextView.frame = CGRect(x: 24, y: 392, width: 320, height: 120)
        notesTextView.font = UIFont.preferredFont(forTextStyle: .body)
        notesTextView.adjustsFontForContentSizeCategory = true
        notesTextView.isEditable = false
        notesTextView.text = "Leave with a neighbour."
        notesTextView.accessibilityLabel = "Delivery notes"
        view.addSubview(notesTextView)
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
