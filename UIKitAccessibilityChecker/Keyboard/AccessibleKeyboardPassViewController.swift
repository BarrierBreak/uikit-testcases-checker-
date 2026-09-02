import UIKit

/// A custom control that correctly opts into hardware-keyboard focus: overrides
/// canBecomeFocused, and wires the same target-action to both touch (.touchUpInside) and
/// keyboard Select/Space (.primaryActionTriggered) — the same action fires either way, and
/// the system focus engine draws its own default highlight around it once focused, with no
/// manual focus-ring drawing needed.
final class KeyboardAccessibleChip: UIControl {
    private let label = UILabel()
    var title: String = "" {
        didSet {
            label.text = title
            accessibilityLabel = title
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = true
        accessibilityTraits = .button
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 10
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var canBecomeFocused: Bool { true }
}

final class AccessibleKeyboardPassViewController: UIViewController {

    private let favoriteChip = KeyboardAccessibleChip().srcLine()
    private let notificationsChip = KeyboardAccessibleChip().srcLine()

    private var isFavorited = false
    private var notificationsOn = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accessible Keyboard (Pass)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }

    private func buildLayout() {
        favoriteChip.title = "Add to favorites"
        favoriteChip.accessibilityValue = "Not added"
        favoriteChip.addTarget(self, action: #selector(toggleFavorite), for: [.touchUpInside, .primaryActionTriggered])

        notificationsChip.title = "Enable notifications"
        notificationsChip.accessibilityValue = "Off"
        notificationsChip.addTarget(self, action: #selector(toggleNotifications), for: [.touchUpInside, .primaryActionTriggered])

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView(arrangedSubviews: [
            sectionLabel("Custom controls — hardware-keyboard focusable"),
            favoriteChip,
            notificationsChip
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    @objc private func toggleFavorite() {
        isFavorited.toggle()
        favoriteChip.accessibilityValue = isFavorited ? "Added" : "Not added"
    }

    @objc private func toggleNotifications() {
        notificationsOn.toggle()
        notificationsChip.accessibilityValue = notificationsOn ? "On" : "Off"
    }
}
