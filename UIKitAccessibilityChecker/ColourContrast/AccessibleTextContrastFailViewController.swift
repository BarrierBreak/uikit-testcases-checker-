import UIKit

/// TEXT CONTRAST — Fail tier, solid backgrounds.
///
/// Every ratio here is below 3:1, which is the floor for large text, so
/// nothing on this screen passes at any size or weight and no exemption
/// applies. There is no threshold subtlety to get right — if a checker
/// misses these it is broken, not merely imprecise.
///
/// Two rows are worth separate attention because they fail in a way that
/// looks like the opposite of a contrast bug:
///
///   • Row 7 is dark-on-dark rather than light-on-light. Tools that sample
///     text colour and assume a light background, or that hardcode white
///     as the comparison, will pass it.
///   • Row 10 is white text on white background — a real regression shape,
///     usually from a theme change that updated one colour and not the
///     other. The text is invisible, the ratio is 1.00:1, and the label is
///     still in the accessibility tree announcing content nobody can see.
///
/// Scenarios covered (10):
///   1.  Body 17pt regular      #B4B4B4 on #FFFFFF — 2.07:1
///   2.  Large 18pt regular     #B4B4B4 on #FFFFFF — 2.07:1
///   3.  Bold 14pt              #B4B4B4 on #FFFFFF — 2.07:1
///   4.  Button title on tint   #FFFFFF on #34C759 — 2.22:1
///   5.  Caption 13pt           #A6A6A6 on #FFFFFF — 2.43:1
///   6.  Link text 15pt         #7EB8F0 on #FFFFFF — 2.10:1
///   7.  Dark on dark 15pt      #5A5A5E on #1C1C1E — 2.48:1
///   8.  Badge 11pt on tint     #FFFFFF on #7FC4F0 — 1.90:1
///   9.  Error 13pt             #FF9A94 on #FFFFFF — 1.85:1
///   10. Invisible text 17pt    #FFFFFF on #FFFFFF — 1.00:1
///
/// Deliberately broken; reference only.
final class AccessibleTextContrastFailViewController: UIViewController {

    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        buildLayout()
    }

    private func buildLayout() {
        // 1. Light grey body text at 2.07:1. Below the large-text floor,
        // so increasing the font size does not rescue it.
        let body = label(
            "The quick brown fox jumps over the lazy dog.",
            font: .systemFont(ofSize: 17, weight: .regular),
            color: "#B4B4B4"
        ).srcLine()

        // 2. The same colour at 18pt, to make the point that the size
        // relaxation is a floor of 3:1 and not an exemption.
        let large = label(
            "Large headline text",
            font: .systemFont(ofSize: 18, weight: .regular),
            color: "#B4B4B4"
        ).srcLine()

        // 3. And at 14pt bold, which does qualify as large text and still
        // falls short.
        let bold = label(
            "Bold 14pt is large text and still fails",
            font: .systemFont(ofSize: 14, weight: .bold),
            color: "#B4B4B4"
        ).srcLine()

        // 4. White on the bright system green — 2.22:1. This pairing is
        // everywhere in shipping apps because it looks correct on a
        // designer's calibrated display at full brightness.
        let button = UIButton(type: .custom).srcLine()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(hex: "#34C759")
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)

        // 5. Caption at 2.43:1.
        let caption = label(
            "Last updated 3 minutes ago",
            font: .systemFont(ofSize: 13, weight: .regular),
            color: "#A6A6A6"
        ).srcLine()

        // 6. A pale link colour at 2.10:1. Links carry a second obligation
        // under 1.4.1 — they must not rely on colour alone to be
        // identifiable — but this row fails 1.4.3 on its own terms first.
        let link = label(
            "View documentation",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#7EB8F0"
        ).srcLine()

        // 7. Dark on dark. Same failure, inverted polarity — the text is
        // darker than a light background would be but sits on a near-black
        // panel at 2.48:1.
        let darkPanel = UIView()
        darkPanel.backgroundColor = UIColor(hex: "#1C1C1E")
        darkPanel.layer.cornerRadius = 8
        let darkText = label(
            "Dark text on a dark panel",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#5A5A5E"
        ).srcLine()
        darkText.translatesAutoresizingMaskIntoConstraints = false
        darkPanel.addSubview(darkText)
        NSLayoutConstraint.activate([
            darkText.topAnchor.constraint(equalTo: darkPanel.topAnchor, constant: 12),
            darkText.bottomAnchor.constraint(equalTo: darkPanel.bottomAnchor, constant: -12),
            darkText.leadingAnchor.constraint(equalTo: darkPanel.leadingAnchor, constant: 12),
            darkText.trailingAnchor.constraint(equalTo: darkPanel.trailingAnchor, constant: -12)
        ])

        // 8. Badge at 1.90:1 — small text on a pale tint, the worst
        // combination on the screen.
        let badge = paddedLabel(
            "3 NEW",
            font: .systemFont(ofSize: 11, weight: .bold),
            color: "#FFFFFF",
            background: "#7FC4F0"
        )

        // 9. Error text at 1.85:1. A washed-out red that reads as pink and
        // does not register as an error to anyone.
        let error = label(
            "Enter a valid email address",
            font: .systemFont(ofSize: 13, weight: .regular),
            color: "#FF9A94"
        ).srcLine()

        // 10. White on white — 1.00:1. Invisible, still present in the
        // accessibility tree, still announced by VoiceOver. The mismatch
        // between what is announced and what is visible is the tell.
        let invisible = label(
            "This paragraph is invisible on this background.",
            font: .systemFont(ofSize: 17, weight: .regular),
            color: "#FFFFFF"
        ).srcLine()

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.alignment = .leading
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        [
            row("1. Body 17pt — 2.07:1", body),
            row("2. Large 18pt — 2.07:1", large),
            row("3. Bold 14pt — 2.07:1", bold),
            row("4. Button title — 2.22:1", button),
            row("5. Caption 13pt — 2.43:1", caption),
            row("6. Link 15pt — 2.10:1", link),
            row("7. Dark on dark 15pt — 2.48:1", darkPanel),
            row("8. Badge 11pt — 1.90:1", badge),
            row("9. Error 13pt — 1.85:1", error),
            row("10. Invisible text — 1.00:1", invisible)
        ].forEach { contentStack.addArrangedSubview($0) }

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    // MARK: - Helpers

    private func label(_ text: String, font: UIFont, color: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = font
        l.textColor = UIColor(hex: color)
        l.numberOfLines = 0
        return l
    }

    /// A label inside a coloured container. The contrast question belongs to the LABEL —
    /// that is the view the scan measures — but the container is what the caller holds, so
    /// `line`/`file` are forwarded down to it. `#line` as a default argument expands at the
    /// CALL SITE, so each badge is tagged with the line that built it rather than with a
    /// single line inside this helper, which would collapse them all into one finding.
    private func paddedLabel(_ text: String, font: UIFont, color: String, background: String,
                             line: Int = #line, file: String = #fileID) -> UIView {
        let l = label(text, font: font, color: color).srcLine(line, file: file)
        let container = UIView()
        container.backgroundColor = UIColor(hex: background)
        container.layer.cornerRadius = 6
        l.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(l)
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            l.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            l.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            l.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])
        return container
    }

    private func row(_ caption: String, _ sample: UIView) -> UIView {
        let c = UILabel()
        c.text = caption
        c.font = .systemFont(ofSize: 11, weight: .medium)
        c.textColor = UIColor(hex: "#3D3D3D")
        let stack = UIStackView(arrangedSubviews: [c, sample])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }
}
