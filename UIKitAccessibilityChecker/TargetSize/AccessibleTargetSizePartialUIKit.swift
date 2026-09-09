import UIKit

/// TARGET SIZE — Partial tier.
///
/// The borderline cases, which is where this rule is actually decided. Every control here
/// is close enough to the 24pt line that eyeballing the screen tells you nothing: one
/// clears it exactly, one misses it by 4pt, one is large but crowded, one is small but
/// isolated. Half of them pass and half of them fail, and the difference is measurable
/// rather than visible.
///
/// This tier is the argument for measuring both counts separately. A checker that only
/// looked at size would pass the crowded pair; one that only looked at spacing would pass
/// the undersized control sitting on its own.
///
/// Element-by-element:
///   1. Exactly 24×24, well spaced  — passes both counts, on the line
///   2. Exactly 44×44, exactly 24pt — passes both counts, both on the line
///   3+4. 24×24 pair, 20pt apart    — big enough, 4pt too close
///   5. 20×20, nothing near it      — well spaced, 4pt too small
final class AccessibleTargetSizePartialViewController: UIViewController {

    // MARK: - Controls

    private let exactlyMinimumButton = UIButton(type: .system).srcLine()
    private let exactlySpacedButton = UIButton(type: .system).srcLine()
    private let exactlySpacedNeighbour = UIButton(type: .system).srcLine()
    private let nearlySpacedLeftButton = UIButton(type: .system).srcLine()
    private let nearlySpacedRightButton = UIButton(type: .system).srcLine()
    private let isolatedSmallButton = UIButton(type: .system).srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Target Size (Partial)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 1. Exactly at the minimum on both counts, with nothing near it. This is the
        // smallest control the rule permits, and it should report as "verify" rather than
        // as a pass: 24×24 at the default text size is often under 24 once the label grows.
        configure(exactlyMinimumButton, title: "?", label: "Help",
                  frame: CGRect(x: 24, y: 24, width: 24, height: 24))

        // 2. Both measurements exactly on the line: 44×44 controls with precisely 24pt
        // between them. The boundary is inclusive, so both of these clear it.
        configure(exactlySpacedButton, title: "A", label: "Option A",
                  frame: CGRect(x: 24, y: 100, width: 44, height: 44))
        configure(exactlySpacedNeighbour, title: "B", label: "Option B",
                  frame: CGRect(x: 24 + 44 + 24, y: 100, width: 44, height: 44))

        // 3 and 4. Comfortably sized at 24×24, and 20pt apart — 4pt short. This is the case
        // a size-only checker waves through, and the one a user actually mis-taps.
        configure(nearlySpacedLeftButton, title: "1", label: "Page 1",
                  frame: CGRect(x: 24, y: 180, width: 24, height: 24))
        configure(nearlySpacedRightButton, title: "2", label: "Page 2",
                  frame: CGRect(x: 24 + 24 + 20, y: 180, width: 24, height: 24))

        // 5. The mirror image: 20×20, but nothing within 100pt of it. Spacing cannot buy
        // back size — the finger still has to land on 20 points.
        configure(isolatedSmallButton, image: "star", label: "Favorite",
                  frame: CGRect(x: 24, y: 260, width: 20, height: 20))
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
