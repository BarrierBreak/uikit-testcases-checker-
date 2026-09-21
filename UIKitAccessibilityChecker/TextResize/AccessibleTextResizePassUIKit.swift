import UIKit

/// TEXT RESIZE — Pass tier. WCAG 1.4.4.
///
/// Every label opts into Dynamic Type, so all of them report "Text can be resized"
/// (BB40032) and none reports BB40031.
///
/// The signal the scan reads is `adjustsFontForContentSizeCategory`, not the font's text
/// style. On iOS 18+ `UIFont.systemFont(ofSize:)` returns a descriptor carrying a `.textStyle`
/// key even for a fixed-size font, so the text style alone would report a fixed font as
/// scalable. The flag is the property iOS actually uses to trigger relayout.
///
/// Every label is also given room to grow, so nothing here trips the clipping rule and the
/// tier stays about resizing alone.
///
/// Elements covered (5), one per common text style:
///   1. Title   2. Headline   3. Body   4. Footnote   5. A text view
final class AccessibleTextResizePassViewController: UIViewController {

    private let titleLabel = UILabel().srcLine()
    private let headlineLabel = UILabel().srcLine()
    private let bodyLabel = UILabel().srcLine()
    private let footnoteLabel = UILabel().srcLine()
    private let notesTextView = UITextView().srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Text Resize (Pass)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        configure(titleLabel, text: "Account settings", style: .title1,
                  frame: CGRect(x: 24, y: 24, width: 320, height: 80))
        configure(headlineLabel, text: "Notifications", style: .headline,
                  frame: CGRect(x: 24, y: 116, width: 320, height: 60))
        configure(bodyLabel,
                  text: "Choose which updates you want to receive about your orders.",
                  style: .body, frame: CGRect(x: 24, y: 188, width: 320, height: 120))
        configure(footnoteLabel, text: "You can change this at any time.", style: .footnote,
                  frame: CGRect(x: 24, y: 320, width: 320, height: 60))

        notesTextView.frame = CGRect(x: 24, y: 392, width: 320, height: 140)
        notesTextView.font = UIFont.preferredFont(forTextStyle: .body)
        notesTextView.adjustsFontForContentSizeCategory = true      // the signal that matters
        notesTextView.isEditable = false
        notesTextView.text = "Order updates are sent to the email on your account."
        notesTextView.accessibilityLabel = "Account notes"
        view.addSubview(notesTextView)
    }

    private func configure(_ label: UILabel, text: String,
                           style: UIFont.TextStyle, frame: CGRect) {
        label.frame = frame
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true              // the signal that matters
        label.textColor = .label
        view.addSubview(label)
    }
}
