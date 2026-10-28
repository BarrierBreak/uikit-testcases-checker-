import UIKit

/// SCREEN TITLE — Partial tier.
///
/// The screen sets no `title` and no visible navigation title, only the navigation item's
/// accessibility label. That is enough for VoiceOver, so it still counts as titled and is
/// reported once as BB40099 — but a sighted user sees an empty navigation bar.
///
/// Elements covered (1):
///   1. The screen — navigationItem.accessibilityLabel only   → BB40099 Pass
final class AccessibleScreenTitlePartialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = nil
        navigationItem.accessibilityLabel = "Order summary"
        let heading = UILabel(frame: CGRect(x: 24, y: 24, width: view.bounds.width - 48, height: 28)).srcLine()
        heading.text = "Your order"
        heading.font = .preferredFont(forTextStyle: .title2)
        heading.autoresizingMask = [.flexibleWidth]
        view.addSubview(heading)

        let detail = UILabel(frame: CGRect(x: 24, y: 64, width: view.bounds.width - 48, height: 22)).srcLine()
        detail.text = "Two items, arriving Friday"
        detail.autoresizingMask = [.flexibleWidth]
        view.addSubview(detail)
    }
}
