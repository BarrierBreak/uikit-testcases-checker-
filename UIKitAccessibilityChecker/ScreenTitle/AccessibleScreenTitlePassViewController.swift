import UIKit

/// SCREEN TITLE — Pass tier.
///
/// The screen sets `title`, so VoiceOver and the navigation bar both say where the user is.
/// Reported once, for the screen, as BB40099 "Title is specified for screen".
///
/// Elements covered (1):
///   1. The screen — title = "Order summary"        → BB40099 Pass
final class AccessibleScreenTitlePassViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Order summary"
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
