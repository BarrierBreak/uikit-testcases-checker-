import UIKit

/// TEXT RESIZE — Fail tier. WCAG 1.4.4.
///
/// No label here responds to the reader's text-size setting, so all of them report
/// "Text fails to resize" (BB40031). Turning Larger Text up to maximum changes nothing on
/// this screen, which is the defect.
///
/// Each label gets there a different way, because these are the four shapes that actually
/// appear in production code:
///   1. Hard-coded point size, flag off             — the common case
///   2. Preferred font, but the flag left off       — the subtle one: the font is scalable,
///                                                     the label just never asks to relayout
///   3. Custom font at a fixed size
///   4. Bold system font at a fixed size
///   5. A text view with a fixed font
///
/// Every label has room to spare, so clipping is not also reported and the tier stays about
/// resizing alone.
final class AccessibleTextResizeFailViewController: UIViewController {

    private let fixedSizeLabel = UILabel().srcLine()
    private let flagOffLabel = UILabel().srcLine()
    private let customFontLabel = UILabel().srcLine()
    private let boldFixedLabel = UILabel().srcLine()
    private let notesTextView = UITextView().srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Text Resize (Fail)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        // 1. A literal point size and no opt-in.
        configure(fixedSizeLabel, text: "Account settings",
                  font: .systemFont(ofSize: 22),
                  frame: CGRect(x: 24, y: 24, width: 320, height: 60))

        // 2. The scalable font is there, but adjustsFontForContentSizeCategory is never set,
        // so iOS has no reason to relayout when the setting changes. Easy to miss in review
        // precisely because the font line looks correct.
        configure(flagOffLabel, text: "Notifications",
                  font: UIFont.preferredFont(forTextStyle: .headline),
                  frame: CGRect(x: 24, y: 96, width: 320, height: 60))

        // 3. A custom face pinned to a fixed size.
        configure(customFontLabel, text: "Choose which updates you want to receive.",
                  font: UIFont(name: "Helvetica", size: 15) ?? .systemFont(ofSize: 15),
                  frame: CGRect(x: 24, y: 168, width: 320, height: 80))

        // 4. Bold at a fixed size — weight is not the problem, the fixed size is.
        configure(boldFixedLabel, text: "You can change this at any time.",
                  font: .boldSystemFont(ofSize: 13),
                  frame: CGRect(x: 24, y: 260, width: 320, height: 60))

        notesTextView.frame = CGRect(x: 24, y: 332, width: 320, height: 140)
        notesTextView.font = .systemFont(ofSize: 15)
        notesTextView.adjustsFontForContentSizeCategory = false
        notesTextView.isEditable = false
        notesTextView.text = "Order updates are sent to the email on your account."
        notesTextView.accessibilityLabel = "Account notes"
        view.addSubview(notesTextView)
    }

    private func configure(_ label: UILabel, text: String, font: UIFont, frame: CGRect) {
        label.frame = frame
        label.text = text
        label.numberOfLines = 0
        label.font = font
        label.adjustsFontForContentSizeCategory = false
        label.textColor = .label
        view.addSubview(label)
    }
}
