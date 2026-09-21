import UIKit

/// TEXT RESIZE — Partial tier. WCAG 1.4.4.
///
/// The half-migrated screen, which is what most real codebases look like: the body copy was
/// moved onto Dynamic Type and the chrome around it was not. The scan should report both
/// "Text can be resized" (BB40032) and "Text fails to resize" (BB40031) on the same screen,
/// which is what separates this tier from Pass and Fail.
///
/// Elements covered (5): 3 scale, 2 do not.
///   1. Title, preferred font + flag        — pass
///   2. Body copy, preferred font + flag    — pass
///   3. Footnote, preferred font + flag     — pass
///   4. Badge, hard-coded 11pt              — FAIL
///   5. Tab caption, hard-coded 10pt        — FAIL
///
/// Both failures are small text, which is the pattern worth noticing: fixed sizes survive
/// longest exactly where the text is already hardest to read.
final class AccessibleTextResizePartialViewController: UIViewController {

    private let titleLabel = UILabel().srcLine()
    private let bodyLabel = UILabel().srcLine()
    private let footnoteLabel = UILabel().srcLine()
    private let badgeLabel = UILabel().srcLine()
    private let tabCaptionLabel = UILabel().srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Text Resize (Partial)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        // 1-3. Migrated.
        configure(titleLabel, text: "Your orders",
                  font: UIFont.preferredFont(forTextStyle: .title1), scales: true,
                  frame: CGRect(x: 24, y: 24, width: 320, height: 80))
        configure(bodyLabel, text: "Track a delivery or start a return.",
                  font: UIFont.preferredFont(forTextStyle: .body), scales: true,
                  frame: CGRect(x: 24, y: 116, width: 320, height: 80))
        configure(footnoteLabel, text: "Returns are free within 30 days.",
                  font: UIFont.preferredFont(forTextStyle: .footnote), scales: true,
                  frame: CGRect(x: 24, y: 208, width: 320, height: 60))

        // 4-5. Not migrated.
        configure(badgeLabel, text: "2 items", font: .systemFont(ofSize: 11), scales: false,
                  frame: CGRect(x: 24, y: 280, width: 200, height: 40))
        configure(tabCaptionLabel, text: "Orders", font: .systemFont(ofSize: 10), scales: false,
                  frame: CGRect(x: 24, y: 332, width: 200, height: 40))
    }

    private func configure(_ label: UILabel, text: String, font: UIFont,
                           scales: Bool, frame: CGRect) {
        label.frame = frame
        label.text = text
        label.numberOfLines = 0
        label.font = font
        label.adjustsFontForContentSizeCategory = scales
        label.textColor = .label
        view.addSubview(label)
    }
}
