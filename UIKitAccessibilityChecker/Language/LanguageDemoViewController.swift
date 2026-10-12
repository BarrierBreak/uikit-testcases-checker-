import UIKit

/// Shared layout for the three Language screens. A screen supplies its items; each item is a
/// piece of text and the speech language the app declared for it (`accessibilityLanguage`),
/// or nil when the app declared none.
///
/// The app under test runs in English, so "en" is the app's language. Every sentence is long
/// enough for the language recognizer to be sure which language it is written in.
class LanguageDemoViewController: UIViewController {

    struct Item {
        let text: String
        let language: String?
        var isButton = false
    }

    var screenTitle: String { "" }
    var items: [Item] { [] }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = .systemBackground
        var y: CGFloat = 24
        for (index, item) in items.enumerated() {
            let control: UIView
            if item.isButton {
                let button = UIButton(type: .system).srcLine()
                button.setTitle(item.text, for: .normal)
                button.titleLabel?.numberOfLines = 0
                button.contentHorizontalAlignment = .leading
                control = button
            } else {
                let label = UILabel().srcLine()
                label.text = item.text
                label.numberOfLines = 0
                control = label
            }
            control.tag = index
            control.accessibilityLanguage = item.language
            control.frame = CGRect(x: 24, y: y, width: view.bounds.width - 48, height: 52)
            control.autoresizingMask = [.flexibleWidth]
            view.addSubview(control)
            y += 72
        }
    }
}
