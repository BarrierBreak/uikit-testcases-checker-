import UIKit

/// TEXT CONTRAST — Partial tier, composited and adaptive.
///
/// The unifying failure here is CONFIGURATION DEPENDENCE. Every sample
/// passes somewhere: in light mode, at the default text size, at the left
/// end of the gradient, with Increase Contrast off, or on the part of the
/// photo that happens to be dark. Test once in one configuration and this
/// entire screen looks compliant.
///
/// That makes this the tier that determines whether the ruleset is
/// genuinely useful. A checker that samples one pixel, or reads the
/// assigned colour instead of the composited one, or runs only in light
/// mode at the default content size, reports zero findings on this file.
///
/// Scenarios covered (10):
///   1.  Label alpha 0.5        effective #808080 on #FFFFFF — 3.95:1
///                              (passes as large text, fails as normal)
///   2.  Background alpha 0.6   #FFFFFF on effective #777778 — 4.47:1
///                              (0.03 under the bar)
///   3.  Stacked layers         resolves lighter than either layer implies
///   4.  Blur material          #767676 on ~#F2F2F2 — 4.06:1
///   5.  Vibrancy label         secondary vibrancy on a light material
///   6.  Gradient               6.57:1 at one end, 2.88:1 at the other
///   7.  Image + weak scrim     scrim only 30% — 3.11:1 worst point
///   8.  Dark mode              7.00:1 light, 2.48:1 dark — one hardcoded grey
///   9.  High contrast          ignores accessibilityContrast entirely
///   10. Dynamic Type           18pt passes as large at default, becomes
///                              normal text at xSmall and fails
///
/// Scenario 10 deserves its own rule. The label is 18pt at the default
/// content size, which is large text needing 3:1, and 3.87:1 clears it. At
/// the xSmall content size the scaled font renders below 18pt, the text
/// becomes normal text needing 4.5:1, and the same colour now fails. The
/// threshold must be chosen from the RENDERED size at the content size
/// under test, not from the nominal size in the source.
final class AccessibleTextContrastCompositedPartialViewController: UIViewController {

    private let contentStack = UIStackView()
    private let adaptiveLabel = UILabel().srcLine()
    private let contrastLabel = UILabel().srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Composited Contrast (Partial)"
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        buildLayout()
    }

    private func buildLayout() {
        // 1. Alpha 0.5 composites black to #808080 — 3.95:1. Enough for
        // large text, short for the 17pt body text it is used on. Reading
        // the assigned colour would report 21:1.
        let alphaLabel = label(
            "Label drawn at 50% alpha",
            font: .systemFont(ofSize: 17, weight: .regular),
            color: "#000000"
        ).srcLine()
        alphaLabel.alpha = 0.5

        // 2. Background alpha 0.6 composites #1C1C1E over white to
        // #777778, giving white text 4.47:1 — three hundredths under AA.
        // The panel looks solidly dark; it is not.
        let translucentPanel = UIView()
        translucentPanel.backgroundColor = UIColor(hex: "#1C1C1E").withAlphaComponent(0.6)
        translucentPanel.layer.cornerRadius = 8
        let onPanel = label(
            "White text on a translucent panel",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#FFFFFF"
        ).srcLine()
        embed(onPanel, in: translucentPanel)

        // 3. Stacked layers, each individually plausible. Two 0.4-alpha
        // dark layers over white do not compose to a dark background —
        // they resolve to a mid grey, and white text on it falls short.
        // Resolving only the immediate parent gives a passing answer.
        let outerLayer = UIView()
        outerLayer.backgroundColor = UIColor(hex: "#1C1C1E").withAlphaComponent(0.4)
        outerLayer.layer.cornerRadius = 8
        let innerLayer = UIView()
        innerLayer.backgroundColor = UIColor(hex: "#1C1C1E").withAlphaComponent(0.4)
        innerLayer.layer.cornerRadius = 8
        let onLayers = label(
            "Text over two translucent layers",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#FFFFFF"
        ).srcLine()
        embed(onLayers, in: innerLayer)
        embed(innerLayer, in: outerLayer, inset: 6)

        // 4. Blur material at 4.06:1. Passes as large text, fails at the
        // 15pt used here. Blur also makes the background depend on what is
        // scrolling underneath, so this ratio is the best case.
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
        blurView.layer.cornerRadius = 8
        blurView.clipsToBounds = true
        let onBlur = label(
            "Text over a blur material",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#767676"
        ).srcLine()
        onBlur.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(onBlur)
        NSLayoutConstraint.activate([
            onBlur.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 12),
            onBlur.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -12),
            onBlur.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 12),
            onBlur.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -12)
        ])

        // 5. Secondary vibrancy on body text. Vibrancy is designed to sink
        // text into its material, and the secondary level sinks it further.
        // The resulting colour is not knowable from the source at all —
        // it is computed by the system from the material and the backdrop,
        // which is itself a finding: the value cannot be verified
        // statically, so this needs a rendered-pixel check.
        let vibrancyHost = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
        vibrancyHost.layer.cornerRadius = 8
        vibrancyHost.clipsToBounds = true
        let vibrancyView = UIVisualEffectView(
            effect: UIVibrancyEffect(
                blurEffect: UIBlurEffect(style: .systemMaterialLight),
                style: .secondaryLabel
            )
        )
        let vibrantLabel = UILabel().srcLine()
        vibrantLabel.text = "Secondary vibrancy body text"
        vibrantLabel.font = .systemFont(ofSize: 15, weight: .regular)
        vibrantLabel.numberOfLines = 0
        vibrantLabel.translatesAutoresizingMaskIntoConstraints = false
        vibrancyView.contentView.addSubview(vibrantLabel)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyHost.contentView.addSubview(vibrancyView)
        NSLayoutConstraint.activate([
            vibrancyView.topAnchor.constraint(equalTo: vibrancyHost.contentView.topAnchor),
            vibrancyView.bottomAnchor.constraint(equalTo: vibrancyHost.contentView.bottomAnchor),
            vibrancyView.leadingAnchor.constraint(equalTo: vibrancyHost.contentView.leadingAnchor),
            vibrancyView.trailingAnchor.constraint(equalTo: vibrancyHost.contentView.trailingAnchor),
            vibrantLabel.topAnchor.constraint(equalTo: vibrancyView.contentView.topAnchor, constant: 12),
            vibrantLabel.bottomAnchor.constraint(equalTo: vibrancyView.contentView.bottomAnchor, constant: -12),
            vibrantLabel.leadingAnchor.constraint(equalTo: vibrancyView.contentView.leadingAnchor, constant: 12),
            vibrantLabel.trailingAnchor.constraint(equalTo: vibrancyView.contentView.trailingAnchor, constant: -12)
        ])

        // 6. Gradient from #0B5FA5 to #3AA0E0. White text is 6.57:1 at the
        // left edge and 2.88:1 at the right, so the first half of the
        // string passes and the second half does not. Sampling the start
        // of the text, or its centre, both give a passing result.
        let gradientView = GradientLabelView(
            text: "This sentence starts readable and ends unreadable",
            from: UIColor(hex: "#0B5FA5"),
            to: UIColor(hex: "#3AA0E0"),
            textColor: UIColor(hex: "#FFFFFF")
        )

        // 7. Photo with a 30% scrim — 3.11:1. Large-text territory only,
        // and the caption is 15pt. A scrim that exists is easily mistaken
        // for a scrim that is sufficient.
        let imageCard = ScrimmedImageLabelView(
            text: "Caption over a photo",
            imageColor: UIColor(hex: "#C8D2DC"),
            scrimAlpha: 0.30,
            textColor: UIColor(hex: "#FFFFFF")
        )

        // 8. One hardcoded grey for both appearances. 7.00:1 in light,
        // 2.48:1 in dark. Light-mode-only testing never sees this.
        adaptiveLabel.text = "Same grey in both appearances"
        adaptiveLabel.font = .systemFont(ofSize: 17, weight: .regular)
        adaptiveLabel.textColor = UIColor(hex: "#595959")

        // 9. Increase Contrast is never consulted. 3.44:1 in both states —
        // a user who turns the setting on to cope gets no change at all.
        contrastLabel.text = "Ignores Increase Contrast"
        contrastLabel.font = .systemFont(ofSize: 15, weight: .regular)
        contrastLabel.textColor = UIColor(hex: "#8A8A8E")

        // 10. 18pt at the default content size, so large text at 3:1 and
        // 3.87:1 passes. At xSmall the rendered size drops below 18pt, the
        // threshold becomes 4.5:1, and the same colour fails.
        let scaled = UIFontMetrics(forTextStyle: .body)
            .scaledFont(for: .systemFont(ofSize: 18, weight: .regular))
        let dynamicLabel = label(
            "Large at default size, normal text at xSmall",
            font: scaled,
            color: "#8E8E93"
        ).srcLine()
        dynamicLabel.adjustsFontForContentSizeCategory = true

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        [
            row("1. Label alpha 0.5 — 3.95:1 (large only)", alphaLabel),
            row("2. Background alpha 0.6 — 4.47:1 (AA fail)", translucentPanel),
            row("3. Stacked layers — resolves mid grey", outerLayer),
            row("4. Blur material — 4.06:1 (large only)", blurView),
            row("5. Secondary vibrancy — not statically knowable", vibrancyHost),
            row("6. Gradient — 6.57:1 → 2.88:1 across the text", gradientView),
            row("7. Image + 30% scrim — 3.11:1 worst point", imageCard),
            row("8. Dark mode — 7.00 light / 2.48 dark", adaptiveLabel),
            row("9. High contrast — 3.44:1 in both states", contrastLabel),
            row("10. Dynamic Type — passes at default, fails at xSmall", dynamicLabel)
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

    // No traitCollectionDidChange override — scenario 9's whole point.

    // MARK: - Helpers

    private func label(_ text: String, font: UIFont, color: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = font
        l.textColor = UIColor(hex: color)
        l.numberOfLines = 0
        return l
    }

    private func embed(_ child: UIView, in parent: UIView, inset: CGFloat = 12) {
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor, constant: inset),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -inset),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: inset),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -inset)
        ])
    }

    private func row(_ caption: String, _ sample: UIView) -> UIView {
        let c = UILabel()
        c.text = caption
        c.font = .systemFont(ofSize: 11, weight: .medium)
        c.textColor = UIColor(hex: "#3D3D3D")
        c.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [c, sample])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}
