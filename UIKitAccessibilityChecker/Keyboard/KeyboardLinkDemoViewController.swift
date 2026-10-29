import UIKit

/// Shared layout for the three Keyboard Link screens. Each item is a link and how a keyboard
/// can (or cannot) use it.
class KeyboardLinkDemoViewController: UIViewController {

    enum Kind {
        /// A UIButton carrying the link trait: Tab reaches it and Space/Return triggers it.
        case nativeLink
        /// A custom view that can take focus and answers a Select press itself
        /// (`accessibilityActivate`).
        case operableCustomLink
        /// A label-like view with the link trait and a tap gesture: Tab skips it.
        case unreachableCustomLink
        /// A custom view that takes focus, but a Select press has nothing to trigger.
        case inertCustomLink
    }

    struct Item {
        let title: String
        let kind: Kind
    }

    var screenTitle: String { "" }
    var items: [Item] { [] }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = .systemBackground
        var y: CGFloat = 24
        for (index, item) in items.enumerated() {
            let link: UIView
            switch item.kind {
            case .nativeLink:
                let button = UIButton(type: .system)
                button.setTitle(item.title, for: .normal)
                button.addAction(UIAction { _ in }, for: .primaryActionTriggered)
                button.accessibilityTraits = .link
                link = button
            case .operableCustomLink:
                let custom = OperableLinkView(title: item.title)
                link = custom
            case .unreachableCustomLink:
                link = TapOnlyLinkView(title: item.title, focusable: false)
            case .inertCustomLink:
                link = TapOnlyLinkView(title: item.title, focusable: true)
            }
            link.srcLine()
            // Built in one loop, so the links share a source line; the tag keeps one link's
            // finding from being merged into another's.
            link.tag = index
            link.frame = CGRect(x: 24, y: y, width: view.bounds.width - 48, height: 50)
            link.autoresizingMask = [.flexibleWidth]
            view.addSubview(link)
            y += 72
        }
    }
}

/// A link built from a plain view: the link trait and a tap gesture, nothing a keyboard can use.
final class TapOnlyLinkView: UIView {
    private let focusable: Bool

    init(title: String, focusable: Bool) {
        self.focusable = focusable
        super.init(frame: .zero)
        let label = UILabel()
        label.text = title
        label.textColor = .link
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(label)
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityTraits = .link
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(open)))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var canBecomeFocused: Bool { focusable }

    @objc private func open() {}
}

/// A link built from a plain view that answers a keyboard Select press itself.
final class OperableLinkView: UIView {

    init(title: String) {
        super.init(frame: .zero)
        let label = UILabel()
        label.text = title
        label.textColor = .link
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(label)
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityTraits = .link
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(open)))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var canBecomeFocused: Bool { true }

    override func accessibilityActivate() -> Bool {
        open()
        return true
    }

    @objc private func open() {}
}
