import UIKit

/// TEXT CONTRAST — Fail tier, composited and adaptive.
///
/// Every scenario is below 3:1 once composited, in every configuration, at
/// every content size. Nothing here is rescued by a large font or a
/// different appearance.
///
/// The reason this tier still matters after the solid-background Fail file
/// is that each of these reads as a HIGH-contrast pairing in the source.
/// Row 1 assigns pure black. Row 2 puts white on near-black. Row 8 uses
/// the system label colour. A checker that reads assigned colours and never
/// composites will report 21:1, 17:1 and 15:1 respectively — the three
/// highest numbers on the screen, for the three least readable rows.
///
/// Scenarios covered (10):
///   1.  Label alpha 0.35        effective #A6A6A6 on #FFFFFF — 2.43:1
///   2.  Background alpha 0.4    #FFFFFF on effective #A4A4A5 — 2.49:1
///   3.  Stacked layers          three light layers, text near-invisible
///   4.  Blur material           #9E9EA3 on ~#F2F2F2 — 2.38:1
///   5.  Vibrancy on a mismatched material — unreadable and unverifiable
///   6.  Gradient                2.88:1 → 1.90:1 across the text
///   7.  Image, no scrim         white on #C8D2DC — 1.53:1
///   8.  Dark mode inverted      dark text kept in dark mode — 2.48:1
///   9.  High contrast inverted  LIGHTENS when Increase Contrast is on
///   10. Dynamic Type            fails at every content size — 2.10:1
///
/// Scenario 9 is the sharpest failure in the file: the app reads
/// accessibilityContrast correctly and then moves the colour the wrong
/// way, so the accessibility setting actively makes the text worse for the
/// user who enabled it.
/// Deliberately broken; reference only.
final class AccessibleTextContrastCompositedFailViewController: UIViewController {

    private let contentStack = UIStackView()
    private let contrastLabel = UILabel().srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        buildLayout()
        applyContrastAwareColors()
    }

    private func buildLayout() {
        // 1. Pure black at 0.35 alpha composites to #A6A6A6 — 2.43:1. The
        // source says #000000, which is the maximum possible contrast.
        let alphaLabel = label(
            "Label drawn at 35% alpha",
            font: .systemFont(ofSize: 17, weight: .regular),
            color: "#000000"
        ).srcLine()
        alphaLabel.alpha = 0.35

        // 2. Near-black panel at 0.4 alpha composites to #A4A4A5, so white
        // text sits at 2.49:1. The source pairing is #FFFFFF on #1C1C1E,
        // which computes to 17:1 if the alpha is ignored.
        let translucentPanel = UIView()
        translucentPanel.backgroundColor = UIColor(hex: "#1C1C1E").withAlphaComponent(0.4)
        translucentPanel.layer.cornerRadius = 8
        let onPanel = label(
            "White text on a translucent panel",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#FFFFFF"
        ).srcLine()
        embed(onPanel, in: translucentPanel)

        // 3. Three stacked light layers over white. Each is nearly
        // transparent, the composite is barely darker than the page, and
        // white text on it is effectively invisible.
        let outerLayer = UIView()
        outerLayer.backgroundColor = UIColor(hex: "#1C1C1E").withAlphaComponent(0.15)
        outerLayer.layer.cornerRadius = 8
        let middleLayer = UIView()
        middleLayer.backgroundColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.5)
        middleLayer.layer.cornerRadius = 8
        let innerLayer = UIView()
        innerLayer.backgroundColor = UIColor(hex: "#1C1C1E").withAlphaComponent(0.1)
        innerLayer.layer.cornerRadius = 8
        let onLayers = label(
            "Text over three translucent layers",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#FFFFFF"
        ).srcLine()
        embed(onLayers, in: innerLayer)
        embed(innerLayer, in: middleLayer, inset: 4)
        embed(middleLayer, in: outerLayer, inset: 4)

        // 4. Light grey on a light material — 2.38:1.
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
        blurView.layer.cornerRadius = 8
        blurView.clipsToBounds = true
        let onBlur = label(
            "Text over a blur material",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#9E9EA3"
        ).srcLine()
        onBlur.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(onBlur)
        NSLayoutConstraint.activate([
            onBlur.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 12),
            onBlur.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -12),
            onBlur.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 12),
            onBlur.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -12)
        ])

        // 5. Vibrancy configured against a DIFFERENT blur style than the
        // one it is hosted in. The system cannot compute a sensible colour
        // and the result is both unreadable and impossible to verify from
        // the source at all.
        let vibrancyHost = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        vibrancyHost.layer.cornerRadius = 8
        vibrancyHost.clipsToBounds = true
        let vibrancyView = UIVisualEffectView(
            effect: UIVibrancyEffect(
                blurEffect: UIBlurEffect(style: .systemChromeMaterialDark),
                style: .tertiaryLabel
            )
        )
        let vibrantLabel = UILabel().srcLine()
        vibrantLabel.text = "Tertiary vibrancy, mismatched material"
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

        // 6. A pale gradient — white text runs from 2.88:1 down to 1.90:1,
        // so no point along the string reaches even the large-text floor.
        let gradientView = GradientLabelView(
            text: "Unreadable across the whole gradient",
            from: UIColor(hex: "#3AA0E0"),
            to: UIColor(hex: "#7FC4F0"),
            textColor: UIColor(hex: "#FFFFFF")
        )

        // 7. No scrim at all. White caption directly on a light image —
        // 1.53:1. This is the single most common contrast failure in
        // shipping apps, because it is created by swapping a dark hero
        // image for a light one long after the caption was designed.
        let imageCard = ScrimmedImageLabelView(
            text: "Caption over a photo",
            imageColor: UIColor(hex: "#C8D2DC"),
            scrimAlpha: 0.0,
            textColor: UIColor(hex: "#FFFFFF")
        )

        // 8. A dynamic colour that returns a DARK value in dark mode. The
        // developer wrote an appearance-aware colour and inverted the
        // branches, so dark mode gets 2.48:1 while light mode gets 4.54:1.
        let adaptiveLabel = UILabel().srcLine()
        adaptiveLabel.text = "Darker in dark mode"
        adaptiveLabel.font = .systemFont(ofSize: 17, weight: .regular)
        adaptiveLabel.textColor = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: "#5A5A5E")   // 2.48:1 on #1C1C1E
                : UIColor(hex: "#767676")   // 4.54:1 on #FFFFFF
        }
        let darkPanel = UIView()
        darkPanel.backgroundColor = UIColor(hex: "#1C1C1E")
        darkPanel.layer.cornerRadius = 8
        embed(adaptiveLabel, in: darkPanel)

        // 9. Increase Contrast handled backwards. The setting is read
        // correctly and the colour moves the wrong way, so enabling the
        // accessibility feature takes the text from 3.44:1 to 2.07:1.
        contrastLabel.text = "Lightens when Increase Contrast is on"
        contrastLabel.font = .systemFont(ofSize: 15, weight: .regular)

        // 10. Fails at every content size, so there is no configuration in
        // which this one passes — 2.10:1 whether scaled up or down.
        let scaled = UIFontMetrics(forTextStyle: .body)
            .scaledFont(for: .systemFont(ofSize: 17, weight: .regular))
        let dynamicLabel = label(
            "Fails at every Dynamic Type size",
            font: scaled,
            color: "#7EB8F0"
        ).srcLine()
        dynamicLabel.adjustsFontForContentSizeCategory = true

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        [
            row("1. Label alpha 0.35 — 2.43:1", alphaLabel),
            row("2. Background alpha 0.4 — 2.49:1", translucentPanel),
            row("3. Three stacked layers — near invisible", outerLayer),
            row("4. Blur material — 2.38:1", blurView),
            row("5. Mismatched vibrancy — unverifiable", vibrancyHost),
            row("6. Gradient — 2.88:1 → 1.90:1", gradientView),
            row("7. Image, no scrim — 1.53:1", imageCard),
            row("8. Dark mode inverted — 2.48:1 in dark", darkPanel),
            row("9. High contrast inverted — 3.44 → 2.07", contrastLabel),
            row("10. Dynamic Type — 2.10:1 at all sizes", dynamicLabel)
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

    // MARK: - 9. High contrast, inverted

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        if traitCollection.accessibilityContrast != previous?.accessibilityContrast {
            applyContrastAwareColors()
        }
    }

    private func applyContrastAwareColors() {
        contrastLabel.textColor = traitCollection.accessibilityContrast == .high
            ? UIColor(hex: "#B4B4B4")   // 2.07:1 — worse with the setting ON
            : UIColor(hex: "#8A8A8E")   // 3.44:1
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
