import UIKit

/// TARGET SIZE — Pass tier.
///
/// Every control is at least 44×44pt — Apple's guidance, comfortably above WCAG's 24pt
/// floor — with at least 32pt of clear space from its nearest neighbour on every side. All
/// of them report "Verify interactive control minimum target size requirements".
///
/// That is a Validate row rather than a Pass row on purpose, and it is the point of this
/// screen. A frame is measured at one moment: at the default Dynamic Type size, in portrait,
/// on one device width. None of that is preserved when the text grows or the layout reflows,
/// and a control that clears the line by 2pt today can drop under it on the next screen
/// size. The scan reports what it measured and asks a person to confirm it survives.
///
/// Elements covered (7) — every one is measured, none is a defect:
///   1. Primary action button   — 120×44
///   2+3. Toolbar pair          — 44×44 each, 32pt apart horizontally
///   4+5. Stacked actions       — 44×44 each, 32pt apart vertically
///   6. Icon button             — 44×44 with a small glyph inside a full-size target
///   7. Generous action         — 60×60
final class AccessibleTargetSizePassViewController: UIViewController {

    // MARK: - Controls

    private let primaryButton = UIButton(type: .system).srcLine()
    private let toolbarLeftButton = UIButton(type: .system).srcLine()
    private let toolbarRightButton = UIButton(type: .system).srcLine()
    private let stackedFirstButton = UIButton(type: .system).srcLine()
    private let stackedSecondButton = UIButton(type: .system).srcLine()
    private let iconButton = UIButton(type: .system).srcLine()
    private let generousButton = UIButton(type: .system).srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Target Size (Pass)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 1. A full-width primary action. Height is what matters here — a wide button that
        // is only 30pt tall still fails, however easy it looks to hit.
        configure(primaryButton, title: "Continue", label: "Continue",
                  frame: CGRect(x: 24, y: 24, width: 120, height: 44))

        // 2 and 3. A toolbar pair with 32pt between them. Toolbars are where crowding
        // normally creeps in, because the icons are small and the row is short.
        configure(toolbarLeftButton, image: "square.and.arrow.up", label: "Share",
                  frame: CGRect(x: 24, y: 100, width: 44, height: 44))
        configure(toolbarRightButton, image: "trash", label: "Delete",
                  frame: CGRect(x: 24 + 44 + 32, y: 100, width: 44, height: 44))

        // 4 and 5. Vertically stacked actions, 32pt apart. The same gap that reads as
        // generous horizontally is easy to lose vertically in a dense list.
        configure(stackedFirstButton, title: "Edit", label: "Edit",
                  frame: CGRect(x: 24, y: 180, width: 100, height: 44))
        configure(stackedSecondButton, title: "Duplicate", label: "Duplicate",
                  frame: CGRect(x: 24, y: 180 + 44 + 32, width: 100, height: 44))

        // 6. A small glyph in a full-size target. The image is 20pt; the control is 44pt.
        // What the rule measures is the target, not the artwork drawn inside it.
        configure(iconButton, image: "info.circle", label: "More information",
                  frame: CGRect(x: 200, y: 180, width: 44, height: 44))

        // 7. Comfortably past every threshold, with nothing near it.
        configure(generousButton, title: "Done", label: "Done",
                  frame: CGRect(x: 24, y: 330, width: 60, height: 60))
    }

    // MARK: - Helpers

    private func configure(_ button: UIButton, title: String? = nil, image: String? = nil,
                           label: String, frame: CGRect) {
        if let title { button.setTitle(title, for: .normal) }
        if let image { button.setImage(UIImage(systemName: image), for: .normal) }
        button.accessibilityLabel = label
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        button.frame = frame
        view.addSubview(button)
    }
}
