import UIKit

/// TEXT CONTRAST — Pass tier, composited and adaptive.
///
/// The solid-background files test arithmetic on two known colours. This
/// file tests the harder half of the problem: cases where neither the text
/// colour nor the background colour used in the calculation is the one
/// written in the source.
///
/// Four things break the naive two-colour comparison:
///
///   • ALPHA. A label at 0.6 alpha is not its assigned colour. The
///     effective colour is the alpha composite of the label over whatever
///     is behind it, and that composite is what the ratio must use.
///   • LAYERING. Translucent views stack. The effective background is the
///     result of compositing every layer down to an opaque one, which may
///     be several views up the hierarchy.
///   • VARIABILITY. Gradients, images and blur give text a background that
///     differs across the text's own bounding box. The ratio must be
///     computed at the WORST point under the glyphs, not at the centre or
///     the average.
///   • ADAPTATION. Dark mode, the high-contrast setting and Dynamic Type
///     each change the inputs at runtime, so a ratio verified once in one
///     configuration proves nothing about the others.
///
/// Scenarios covered (10), all passing AA in every configuration:
///   1.  Label alpha 0.6         effective #666666 on #FFFFFF — 5.74:1
///   2.  Background alpha 0.85   #FFFFFF on effective #3E3E40 — 10.67:1
///   3.  Two stacked layers      #FFFFFF on effective #3E3E40 — 10.67:1
///   4.  Blur material           #3D3D3D on ~#F2F2F2 — 9.70:1
///   5.  Vibrancy label          opaque label instead — 9.70:1
///   6.  Gradient background     white on #0B5FA5 → #1E6B36 — 6.54:1 worst
///   7.  Text over an image      white on scrimmed #5A5E63 — 6.53:1 worst
///   8.  Dark mode variant       #595959 light / #C7C7CC dark — 7.00 / 10.10
///   9.  High-contrast trait     #595959 normal / #3D3D3D high — 7.00 / 10.86
///   10. Dynamic Type boundary   sized so it passes as NORMAL text — 5.74:1
///
/// Scenario 10 is the one most likely to be missed. An 18pt label is large
/// text and only needs 3:1 — but at the xSmall content size a scaled 18pt
/// font renders smaller than 18pt and becomes normal text needing 4.5:1.
/// The safe approach, used here, is to meet the normal-text threshold so
/// the text is compliant at every content size.
final class AccessibleTextContrastCompositedPassViewController: UIViewController {

    private let contentStack = UIStackView()
    private let adaptiveLabel = UILabel().srcLine()
    private let contrastLabel = UILabel().srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Composited Contrast (Pass)"
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        buildLayout()
        applyContrastAwareColors()
    }

    private func buildLayout() {
        // 1. Label alpha. The assigned colour is pure black, but at 0.6
        // alpha over white the effective colour is #666666. Using the
        // assigned #000000 would report 21:1 and be wrong by a wide
        // margin; the real ratio is 5.74:1, which still passes.
        let alphaLabel = label(
            "Label drawn at 60% alpha",
            font: .systemFont(ofSize: 17, weight: .regular),
            color: "#000000"
        ).srcLine()
        alphaLabel.alpha = 0.6

        // 2. Background alpha. The panel is #1C1C1E at 0.85 over white,
        // compositing to #3E3E40. White text on that is 10.67:1.
        let translucentPanel = UIView()
        translucentPanel.backgroundColor = UIColor(hex: "#1C1C1E").withAlphaComponent(0.85)
        translucentPanel.layer.cornerRadius = 8
        let onPanel = label(
            "White text on a translucent panel",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#FFFFFF"
        ).srcLine()
        embed(onPanel, in: translucentPanel)

        // 3. Two stacked translucent layers. Neither layer alone is
        // opaque, so the effective background is the composite of both
        // over the white view behind them. Resolving only one level up
        // gives the wrong answer.
        let outerLayer = UIView()
        outerLayer.backgroundColor = UIColor(hex: "#1C1C1E").withAlphaComponent(0.5)
        outerLayer.layer.cornerRadius = 8
        let innerLayer = UIView()
        innerLayer.backgroundColor = UIColor(hex: "#1C1C1E").withAlphaComponent(0.7)
        innerLayer.layer.cornerRadius = 8
        let onLayers = label(
            "Text over two translucent layers",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#FFFFFF"
        ).srcLine()
        embed(onLayers, in: innerLayer)
        embed(innerLayer, in: outerLayer, inset: 6)

        // 4. Blur material. A UIVisualEffectView over a light background
        // resolves to roughly #F2F2F2, so the text colour is chosen
        // against that rather than against the wallpaper behind it. The
        // dark grey used here holds up over any light material.
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
        blurView.layer.cornerRadius = 8
        blurView.clipsToBounds = true
        let onBlur = label(
            "Text over a blur material",
            font: .systemFont(ofSize: 15, weight: .regular),
            color: "#3D3D3D"
        ).srcLine()
        onBlur.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(onBlur)
        NSLayoutConstraint.activate([
            onBlur.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 12),
            onBlur.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -12),
            onBlur.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 12),
            onBlur.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -12)
        ])

        // 5. Vibrancy. UIVibrancyEffect deliberately reduces contrast to
        // blend text into its material, which is the opposite of what
        // 1.4.3 requires for primary content. Vibrancy is fine for
        // decorative chrome; here the text that must be read uses a plain
        // opaque colour instead.
        let vibrancyHost = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
        vibrancyHost.layer.cornerRadius = 8
        vibrancyHost.clipsToBounds = true
        let primaryOverMaterial = label(
            "Primary text, no vibrancy applied",
            font: .systemFont(ofSize: 15, weight: .semibold),
            color: "#3D3D3D"
        ).srcLine()
        primaryOverMaterial.translatesAutoresizingMaskIntoConstraints = false
        vibrancyHost.contentView.addSubview(primaryOverMaterial)
        NSLayoutConstraint.activate([
            primaryOverMaterial.topAnchor.constraint(equalTo: vibrancyHost.contentView.topAnchor, constant: 12),
            primaryOverMaterial.bottomAnchor.constraint(equalTo: vibrancyHost.contentView.bottomAnchor, constant: -12),
            primaryOverMaterial.leadingAnchor.constraint(equalTo: vibrancyHost.contentView.leadingAnchor, constant: 12),
            primaryOverMaterial.trailingAnchor.constraint(equalTo: vibrancyHost.contentView.trailingAnchor, constant: -12)
        ])

        // 6. Gradient. Both endpoints are dark enough for white text —
        // 6.57:1 at one end and 6.54:1 at the other — so every point under
        // the glyphs passes. Checking only the midpoint would be luck.
        let gradientView = GradientLabelView(
            text: "White text across a gradient",
            from: UIColor(hex: "#0B5FA5"),
            to: UIColor(hex: "#1E6B36"),
            textColor: UIColor(hex: "#FFFFFF")
        )

        // 7. Text over an image. The image is generated from a known
        // colour so the fixture is deterministic, and a 55% black scrim
        // sits between the image and the text. The scrim is what makes the
        // ratio predictable — without it, contrast depends on whatever
        // photo the user uploaded.
        let imageCard = ScrimmedImageLabelView(
            text: "Caption over a photo",
            imageColor: UIColor(hex: "#C8D2DC"),
            scrimAlpha: 0.55,
            textColor: UIColor(hex: "#FFFFFF")
        )

        // 8. Dark mode. Two explicit colours rather than one fixed value,
        // each verified against its own background: 7.00:1 in light and
        // 10.10:1 in dark. A single hardcoded grey cannot pass both.
        adaptiveLabel.text = "Adapts to light and dark"
        adaptiveLabel.font = .systemFont(ofSize: 17, weight: .regular)
        adaptiveLabel.textColor = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: "#C7C7CC")   // 10.10:1 on #1C1C1E
                : UIColor(hex: "#595959")   // 7.00:1 on #FFFFFF
        }

        // 9. High-contrast trait. When Increase Contrast is on, the system
        // expects content to darken further. This label reads
        // traitCollection.accessibilityContrast and does so.
        contrastLabel.text = "Responds to Increase Contrast"
        contrastLabel.font = .systemFont(ofSize: 15, weight: .regular)

        // 10. Dynamic Type. The font scales, so its rendered size is not
        // the 17pt in the source. This colour meets the NORMAL-text
        // threshold, which holds at every content size — including the
        // small ones where a nominally large font renders under 18pt.
        let scaled = UIFontMetrics(forTextStyle: .body)
            .scaledFont(for: .systemFont(ofSize: 17, weight: .regular))
        let dynamicLabel = label(
            "Scales with Dynamic Type, passes at every size",
            font: scaled,
            color: "#666666"
        ).srcLine()
        dynamicLabel.adjustsFontForContentSizeCategory = true

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        [
            row("1. Label alpha 0.6 — 5.74:1", alphaLabel),
            row("2. Background alpha 0.85 — 10.67:1", translucentPanel),
            row("3. Stacked layers — 10.67:1", outerLayer),
            row("4. Blur material — 9.70:1", blurView),
            row("5. No vibrancy on primary text — 9.70:1", vibrancyHost),
            row("6. Gradient — 6.54:1 worst point", gradientView),
            row("7. Image + 55% scrim — 6.53:1 worst point", imageCard),
            row("8. Dark mode — 7.00 light / 10.10 dark", adaptiveLabel),
            row("9. High contrast — 7.00 / 10.86", contrastLabel),
            row("10. Dynamic Type — 5.74:1 at all sizes", dynamicLabel)
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

    // MARK: - 9. High contrast

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        if traitCollection.accessibilityContrast != previous?.accessibilityContrast {
            applyContrastAwareColors()
        }
    }

    private func applyContrastAwareColors() {
        contrastLabel.textColor = traitCollection.accessibilityContrast == .high
            ? UIColor(hex: "#3D3D3D")   // 10.86:1
            : UIColor(hex: "#595959")   // 7.00:1
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

// MARK: - Shared sample views
// Used by the Partial and Fail tiers too, with different colours passed in,
// so the only difference between tiers is the values rather than the shape.

/// A label over a two-stop linear gradient. The contrast question here is
/// what happens at each end of the gradient, not at its midpoint.
final class GradientLabelView: UIView {

    private let gradient = CAGradientLayer()
    private let label = UILabel()

    init(text: String, from: UIColor, to: UIColor, textColor: UIColor,
         line: Int = #line, file: String = #fileID) {
        super.init(frame: .zero)
        gradient.colors = [from.cgColor, to.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradient)
        layer.cornerRadius = 8
        clipsToBounds = true

        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = textColor
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.srcLine(line, file: file)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}

/// A label over a generated image with an optional black scrim between
/// them. The image is drawn from a fixed colour rather than loaded from an
/// asset, so the effective background is known and the fixture produces the
/// same ratio on every machine.
final class ScrimmedImageLabelView: UIView {

    private let imageView = UIImageView()
    private let scrim = UIView()
    private let label = UILabel()

    init(text: String, imageColor: UIColor, scrimAlpha: CGFloat, textColor: UIColor,
         line: Int = #line, file: String = #fileID) {
        super.init(frame: .zero)
        layer.cornerRadius = 8
        clipsToBounds = true

        imageView.image = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { ctx in
            imageColor.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }
        imageView.contentMode = .scaleToFill

        scrim.backgroundColor = UIColor(hex: "#000000").withAlphaComponent(scrimAlpha)

        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = textColor
        label.numberOfLines = 0
        label.srcLine(line, file: file)

        [imageView, scrim, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            scrim.topAnchor.constraint(equalTo: topAnchor),
            scrim.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrim.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrim.trailingAnchor.constraint(equalTo: trailingAnchor),

            label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
