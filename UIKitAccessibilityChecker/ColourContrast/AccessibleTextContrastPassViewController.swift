import UIKit

/// TEXT CONTRAST — Pass tier, solid backgrounds.
///
/// WCAG 1.4.3 (AA) requires a contrast ratio of at least 4.5:1 for normal
/// text and 3:1 for large text. WCAG 1.4.6 (AAA) raises those to 7:1 and
/// 4.5:1. "Large" means 18pt or larger, or 14pt or larger when bold —
/// measured at the size the text is actually RENDERED, not the size in the
/// source, which matters once Dynamic Type is involved.
///
/// Every colour below is a hardcoded hex with its computed ratio in the
/// comment, so the ruleset has ground truth to assert against rather than a
/// value that has to be eyeballed. Ratios were computed with the WCAG
/// relative-luminance formula against the stated background.
///
/// Scenarios covered (10), all passing AA; those marked AAA pass 1.4.6 too:
///   1.  Body text, 17pt regular        #595959 on #FFFFFF — 7.00:1  (AAA)
///   2.  Large text, 18pt regular       #767676 on #FFFFFF — 4.54:1  (AAA)
///   3.  Bold text, 14pt bold           #767676 on #FFFFFF — 4.54:1  (AAA)
///   4.  Button title, white on tint    #FFFFFF on #0B5FA5 — 6.57:1
///   5.  Caption, 13pt regular          #595959 on #FFFFFF — 7.00:1  (AAA)
///   6.  Cell subtitle, 15pt regular    #666666 on #FFFFFF — 5.74:1
///   7.  Section header, 13pt semibold  #595959 on #FFFFFF — 7.00:1  (AAA)
///   8.  Badge text, 11pt on green      #FFFFFF on #1E6B36 — 6.54:1
///   9.  Error text, 13pt regular       #B3261E on #FFFFFF — 6.54:1
///   10. Disabled button title          #767676 on #FFFFFF — 4.54:1
///
/// Scenario 10 is the exemption case. WCAG 1.4.3 exempts text that is part
/// of an inactive control, so a disabled title has no minimum ratio at all.
/// It is legible here anyway, which is good practice — but a rule that
/// FLAGS a low-contrast disabled control is producing a false positive, and
/// this row exists to prove the rule knows the difference.
final class AccessibleTextContrastPassViewController: UIViewController {

    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Text Contrast (Pass)"
        // Fixed white background so every ratio in this file is computable
        // from two known colours. Nothing is translucent or layered — the
        // composited cases live in the Composited files.
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        buildLayout()
    }

    private func buildLayout() {
        // 1. Body text. 17pt regular is normal text, so the AA threshold is
        // 4.5:1. #595959 clears AAA as well at 7.00:1.
        let body = label(
            "The quick brown fox jumps over the lazy dog.",
            font: .systemFont(ofSize: 17, weight: .regular),
            color: "#595959"
        ).srcLine()

        // 2. Large text. At 18pt the threshold drops to 3:1, so #767676
        // has considerable headroom at 4.54:1 — it also clears the 4.5:1
        // AAA requirement for large text.
        let large = label(
            "Large headline text",
            font: .systemFont(ofSize: 18, weight: .regular),
            color: "#767676"
        ).srcLine()

        // 3. Bold boundary. 14pt bold is the smallest size that counts as
        // large text under WCAG. One point smaller, or one weight lighter,
        // and this same colour would fail — see the Partial file.
        let boldBoundary = label(
            "Bold 14pt counts as large text",
            font: .systemFont(ofSize: 14, weight: .bold),
            color: "#767676"
        ).srcLine()

        // 4. White on a tinted button. The ratio is between the title
        // colour and the button's fill, not the screen background.
        let button = UIButton(type: .custom).srcLine()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(hex: "#0B5FA5")
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)

        // 5. Caption. Small text gets no relaxation — 13pt is normal text
        // and still needs 4.5:1. Secondary text is where most real
        // failures live, because designers treat "secondary" as licence to
        // lighten.
        let caption = label(
            "Last updated 3 minutes ago",
            font: .systemFont(ofSize: 13, weight: .regular),
            color: "#595959"
        ).srcLine()

        // 6. Cell subtitle. 5.74:1 passes AA comfortably but falls short
        // of the 7:1 AAA bar — deliberate, so the ruleset has a case that
        // is correct at AA and reportable at AAA.
        let subtitle = label(
            "Arriving Thursday, 14 March",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#666666"
        ).srcLine()

        // 7. Section header. Uppercase 13pt semibold is still normal text:
        // semibold is not bold, and 13pt is below 14 regardless.
        let header = label(
            "CONNECTIVITY",
            font: .systemFont(ofSize: 13, weight: .semibold),
            color: "#595959"
        ).srcLine()

        // 8. Badge. 11pt white on a dark green fill. The bright system
        // green most apps reach for gives 2.22:1 with white — see Fail.
        let badge = paddedLabel(
            "3 NEW",
            font: .systemFont(ofSize: 11, weight: .bold),
            color: "#FFFFFF",
            background: "#1E6B36"
        )

        // 9. Error text. A darkened red rather than the system red, which
        // only reaches 3.55:1 against white.
        let error = label(
            "Enter a valid email address",
            font: .systemFont(ofSize: 13, weight: .regular),
            color: "#B3261E"
        ).srcLine()

        // 10. Disabled control — EXEMPT under 1.4.3. Legible anyway, but
        // the point of this row is that flagging it would be wrong.
        let disabledButton = UIButton(type: .custom).srcLine()
        disabledButton.setTitle("Save Draft", for: .normal)
        disabledButton.setTitleColor(UIColor(hex: "#767676"), for: .disabled)
        disabledButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        disabledButton.isEnabled = false

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.alignment = .leading
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        [
            row("1. Body 17pt — 7.00:1", body),
            row("2. Large 18pt — 4.54:1", large),
            row("3. Bold 14pt — 4.54:1", boldBoundary),
            row("4. Button title — 6.57:1", button),
            row("5. Caption 13pt — 7.00:1", caption),
            row("6. Cell subtitle 15pt — 5.74:1", subtitle),
            row("7. Section header 13pt — 7.00:1", header),
            row("8. Badge 11pt — 6.54:1", badge),
            row("9. Error 13pt — 6.54:1", error),
            row("10. Disabled title — exempt", disabledButton)
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

    /// The caption above each sample is itself high-contrast, so the
    /// scaffolding of the fixture never becomes a finding.
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

extension UIColor {
    /// Fixed sRGB from a hex string. Deliberately NOT a dynamic or system
    /// colour, so every ratio in these fixtures is deterministic and does
    /// not shift with appearance or accessibility settings.
    convenience init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        let r = CGFloat((value & 0xFF0000) >> 16) / 255
        let g = CGFloat((value & 0x00FF00) >> 8) / 255
        let b = CGFloat(value & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
