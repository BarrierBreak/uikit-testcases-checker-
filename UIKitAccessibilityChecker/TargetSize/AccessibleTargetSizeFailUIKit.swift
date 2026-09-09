import UIKit

/// TARGET SIZE — Fail tier.
///
/// WCAG 2.5.8 checks size first, and that decides whether anything else matters:
///   • at least 24×24pt → passes on size alone, whatever sits next to it;
///   • smaller than that → it passes only if one of the four exceptions applies. The one at
///     work here is SPACING, and it is a circle test: a 24pt-diameter circle centred on the
///     target must not overlap another target, nor another undersized target's circle. In
///     practice that means two undersized targets need their CENTRES at least 24pt apart —
///     so two 20pt icons clear it at a 4pt gap and fail at 2pt, which is much more permissive
///     than "24pt of clear space on every side" and is why the gaps here are so tight.
///
/// So the only shape that fails is a control that is BOTH undersized AND too close to
/// something, and the first eight controls here are each a different flavour of exactly that.
///
/// The last pair is deliberately NOT a failure, and it is the most useful thing on the
/// screen: two full-size controls 10pt apart, reported as Validate. A checker that measured
/// spacing on every control regardless of size would flag them, and it would be wrong to.
///
/// Positions are set with explicit frames rather than a stack view on purpose: this screen
/// is about exact geometry, and a spacing constant that lives in one place is easier to read
/// against the rule than one distributed across constraints.
/// Deliberately broken; reference only.
///
/// Element-by-element:
///   1+2.  Tiny pair          — 16×16 and 20×20, 2pt apart               → FAIL
///   3+4.  Stepper pair       — 20×20 each, 2pt apart horizontally       → FAIL
///   5+6.  Inline list rows   — 80×20 each, 2pt apart vertically         → FAIL
///   7+8.  Overlapping pair   — 20×20 each, on top of one another        → FAIL
///   9+10. Big and crowded    — 60×60 with a neighbour 10pt below it     → VALIDATE,
///                              because size is checked first
final class AccessibleTargetSizeFailViewController: UIViewController {

    // MARK: - Controls

    private let tinyButton = UIButton(type: .system).srcLine()
    private let tinyIconButton = UIButton(type: .system).srcLine()
    private let crowdedLeftButton = UIButton(type: .system).srcLine()
    private let crowdedRightButton = UIButton(type: .system).srcLine()
    private let stackedTopButton = UIButton(type: .system).srcLine()
    private let stackedBottomButton = UIButton(type: .system).srcLine()
    private let overlappingBackButton = UIButton(type: .system).srcLine()
    private let overlappingFrontButton = UIButton(type: .system).srcLine()
    private let bigButton = UIButton(type: .system).srcLine()
    private let bigNeighbourButton = UIButton(type: .system).srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Target Size (Fail)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 1 and 2. Undersized and side by side with 2pt between them: their 24pt circles overlap,
        // so the spacing exception cannot rescue either one.
        configure(tinyButton, title: "×", label: "Dismiss",
                  frame: CGRect(x: 24, y: 24, width: 16, height: 16))
        configure(tinyIconButton, image: "info.circle", label: "More information",
                  frame: CGRect(x: 24 + 16 + 2, y: 24, width: 20, height: 20))

        // 3 and 4. The stepper pair, at the 20×20 a glyph-sized icon button ends up at. Two 20pt
        // targets need more than 4pt between them for their circles to clear; these have 2.
        configure(crowdedLeftButton, title: "−", label: "Decrease",
                  frame: CGRect(x: 24, y: 140, width: 20, height: 20))
        configure(crowdedRightButton, title: "+", label: "Increase",
                  frame: CGRect(x: 24 + 20 + 2, y: 140, width: 20, height: 20))

        // 5 and 6. The same defect on the vertical axis, and the shape inline list actions
        // usually take: wide enough, but only 20pt tall, and 2pt apart.
        configure(stackedTopButton, title: "Edit", label: "Edit",
                  frame: CGRect(x: 24, y: 210, width: 80, height: 20))
        configure(stackedBottomButton, title: "Delete", label: "Delete",
                  frame: CGRect(x: 24, y: 210 + 20 + 2, width: 80, height: 20))

        // 7 and 8. Two undersized controls occupying the same space. There is no gap to
        // measure and no side to attribute it to — whichever is on top takes every tap.
        configure(overlappingBackButton, title: "B", label: "Back layer",
                  frame: CGRect(x: 200, y: 210, width: 20, height: 20))
        configure(overlappingFrontButton, title: "F", label: "Front layer",
                  frame: CGRect(x: 208, y: 218, width: 20, height: 20))

        // 9 and 10. The counter-example, and the reason this screen is worth reading: a
        // generous 60×60 control with a neighbour only 10pt below it. Both are reported as
        // Validate, NOT as failures. Size is checked first, and a control that meets the
        // 24pt minimum passes on that alone — the spacing exception exists to rescue targets
        // that are too small, not to impose a second bar on ones that are big enough. A
        // crowded pair of full-size buttons is a layout choice, not a 2.5.8 failure.
        configure(bigButton, title: "Save", label: "Save",
                  frame: CGRect(x: 24, y: 330, width: 60, height: 60))
        configure(bigNeighbourButton, title: "Cancel", label: "Cancel",
                  frame: CGRect(x: 24, y: 330 + 60 + 10, width: 60, height: 44))
    }

    // MARK: - Helpers

    private func configure(_ button: UIButton, title: String? = nil, image: String? = nil,
                           label: String, frame: CGRect) {
        if let title { button.setTitle(title, for: .normal) }
        if let image { button.setImage(UIImage(systemName: image), for: .normal) }
        button.accessibilityLabel = label
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 6
        button.frame = frame
        view.addSubview(button)
    }
}
