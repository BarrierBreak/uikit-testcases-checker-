import UIKit

/// TEXT CONTRAST — Partial tier, solid backgrounds.
///
/// Nothing here is glaringly low contrast. Every sample is readable to most
/// sighted users in good light, which is exactly why these survive design
/// review. They fail on the arithmetic, and most of them fail by a margin
/// small enough that a checker with sloppy rounding or a wrong size
/// threshold will report them as passing.
///
/// Three distinct kinds of near-miss are represented, and they need
/// different things from the ruleset:
///
///   • ROUNDING — 4.478:1 and 2.995:1 are below their thresholds. A
///     checker that rounds to one decimal before comparing reports 4.5
///     and 3.0 and passes both. Compare at full precision, then round for
///     display only.
///   • THRESHOLD — text that is large enough for 3:1, or is not, depending
///     on a size and weight rule that is easy to implement wrongly. Bold
///     alone does not make text large; it must be 14pt AND bold.
///   • LEVEL — ratios that pass 1.4.3 AA and fail 1.4.6 AAA. Correct or
///     not depending on which level is being tested, so the ruleset must
///     report the level rather than a bare pass/fail.
///
/// Scenarios covered (10):
///   1.  Body 17pt regular      #777777 on #FFFFFF — 4.478:1  fails AA by 0.022
///   2.  Large 18pt regular     #959595 on #FFFFFF — 2.995:1  fails large AA by 0.005
///   3.  Bold 13pt              #8A8A8E on #FFFFFF — 3.44:1   bold but NOT large
///   4.  Button title on tint   #FFFFFF on #2F80ED — 3.87:1   large-only
///   5.  Caption 13pt           #8A8A8E on #FFFFFF — 3.44:1   fails AA
///   6.  Cell subtitle 15pt     #707070 on #FFFFFF — 4.95:1   AA pass, AAA fail
///   7.  Section header 13pt    #6B6B6B on #FFFFFF — 5.33:1   AA pass, AAA fail
///   8.  Badge 11pt on tint     #FFFFFF on #2F80ED — 3.87:1   fails AA at 11pt
///   9.  Error 13pt             #FF3B30 on #FFFFFF — 3.55:1   system red fails
///   10. Placeholder text       #8A8A8E on #FFFFFF — 3.44:1   NOT exempt
///
/// Scenario 10 is the counterpart to the Pass file's disabled control.
/// Placeholder text is real text in an active field and carries the full
/// 4.5:1 requirement. It is frequently mistaken for exempt because it
/// looks like a hint, and UIKit's own default placeholder colour does not
/// meet AA. A ruleset that exempts placeholders is under-reporting.
final class AccessibleTextContrastPartialViewController: UIViewController {

    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Text Contrast (Partial)"
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        buildLayout()
    }

    private func buildLayout() {
        // 1. Body text at 4.478:1. Twenty-two thousandths below the bar.
        // Visually indistinguishable from the Pass file's 4.54:1 sample,
        // and the single most common false negative in contrast tooling.
        let body = label(
            "The quick brown fox jumps over the lazy dog.",
            font: .systemFont(ofSize: 17, weight: .regular),
            color: "#777777"
        ).srcLine()

        // 2. Large text at 2.995:1, five thousandths below the 3:1 bar for
        // large text. Same rounding trap at the other threshold.
        let large = label(
            "Large headline text",
            font: .systemFont(ofSize: 18, weight: .regular),
            color: "#959595"
        ).srcLine()

        // 3. The bold trap. 13pt bold is NOT large text — WCAG requires
        // 14pt or larger when bold. A checker that treats any bold text as
        // large applies 3:1, sees 3.44:1, and passes it. The correct
        // threshold is 4.5:1, which this fails.
        let boldTrap = label(
            "Bold, but only 13pt",
            font: .systemFont(ofSize: 13, weight: .bold),
            color: "#8A8A8E"
        ).srcLine()

        // 4. A very common brand blue. 3.87:1 with white passes as large
        // text and fails as normal, so the same button is compliant with a
        // 20pt title and non-compliant with a 17pt one.
        let button = UIButton(type: .custom).srcLine()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(hex: "#2F80ED")
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)

        // 5. Secondary caption. 3.44:1 — the classic "grey it out because
        // it is less important" failure. Small text has no exemption.
        let caption = label(
            "Last updated 3 minutes ago",
            font: .systemFont(ofSize: 13, weight: .regular),
            color: "#8A8A8E"
        ).srcLine()

        // 6. 4.95:1 — passes 1.4.3 AA, fails 1.4.6 AAA at 7:1. Correct or
        // incorrect entirely depending on the level being tested.
        let subtitle = label(
            "Arriving Thursday, 14 March",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#707070"
        ).srcLine()

        // 7. Same shape: 5.33:1, AA pass and AAA fail.
        let header = label(
            "CONNECTIVITY",
            font: .systemFont(ofSize: 13, weight: .semibold),
            color: "#6B6B6B"
        ).srcLine()

        // 8. Badge at 11pt. Small text on a mid-tone tint — 3.87:1 needs
        // to clear 4.5:1 and does not. Badges are also often the last
        // thing anyone checks.
        let badge = paddedLabel(
            "3 NEW",
            font: .systemFont(ofSize: 11, weight: .bold),
            color: "#FFFFFF",
            background: "#2F80ED"
        )

        // 9. The stock system red against white is 3.55:1. Error text is
        // the worst possible place for a marginal ratio, since it is what
        // the user must read to recover from a mistake.
        let error = label(
            "Enter a valid email address",
            font: .systemFont(ofSize: 13, weight: .regular),
            color: "#FF3B30"
        ).srcLine()

        // 10. Placeholder — NOT exempt, and 3.44:1 fails AA.
        let field = UITextField().srcLine()
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 17, weight: .regular)
        field.textColor = UIColor(hex: "#3D3D3D")
        field.attributedPlaceholder = NSAttributedString(
            string: "Email address",
            attributes: [.foregroundColor: UIColor(hex: "#8A8A8E")]
        )
        field.widthAnchor.constraint(equalToConstant: 260).isActive = true

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.alignment = .leading
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        [
            row("1. Body 17pt — 4.478:1 (AA fail)", body),
            row("2. Large 18pt — 2.995:1 (large AA fail)", large),
            row("3. Bold 13pt — 3.44:1 (not large; AA fail)", boldTrap),
            row("4. Button title — 3.87:1 (large only)", button),
            row("5. Caption 13pt — 3.44:1 (AA fail)", caption),
            row("6. Cell subtitle — 4.95:1 (AA pass, AAA fail)", subtitle),
            row("7. Section header — 5.33:1 (AA pass, AAA fail)", header),
            row("8. Badge 11pt — 3.87:1 (AA fail)", badge),
            row("9. Error 13pt — 3.55:1 (AA fail)", error),
            row("10. Placeholder — 3.44:1 (not exempt)", field)
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
