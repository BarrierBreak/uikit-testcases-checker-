import UIKit

/// SCREEN TITLE — Fail tier.
///
/// The screen sets no title of any kind, so nothing tells a screen-reader user where they are.
/// BB40099 is a Pass rule, so nothing is reported; the missing title is BB40098's.
///
/// Elements covered (1):
///   1. The screen — no title, navigationItem.title or accessibilityLabel   → no BB40099
final class AccessibleScreenTitleFailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = nil
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
