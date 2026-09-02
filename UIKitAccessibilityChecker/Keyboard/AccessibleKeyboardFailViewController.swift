import UIKit

/// A plain UIView + UITapGestureRecognizer standing in for a control. Carries the .button
/// trait and is reachable by touch and VoiceOver, but — deliberately, for this Fail screen —
/// never overrides canBecomeFocused, so it is invisible to hardware-keyboard Tab navigation
/// even though it announces itself as a button.
final class KeyboardInaccessibleChip: UIView {
    private let label = UILabel()
    var title: String = "" {
        didSet {
            label.text = title
            accessibilityLabel = title
        }
    }
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = true
        accessibilityTraits = .button
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 10
        isUserInteractionEnabled = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: 50)
        ])
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func handleTap() { onTap?() }
}

final class AccessibleKeyboardFailViewController: UIViewController {

    private let favoriteChip = KeyboardInaccessibleChip().srcLine()
    private let notificationsChip = KeyboardInaccessibleChip().srcLine()

    private var isFavorited = false
    private var notificationsOn = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accessible Keyboard (Fail)"
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
        favoriteChip.onTap = { [weak self] in
            guard let self else { return }
            self.isFavorited.toggle()
            self.favoriteChip.accessibilityValue = self.isFavorited ? "Added" : "Not added"
        }

        notificationsChip.title = "Enable notifications"
        notificationsChip.accessibilityValue = "Off"
        notificationsChip.onTap = { [weak self] in
            guard let self else { return }
            self.notificationsOn.toggle()
            self.notificationsChip.accessibilityValue = self.notificationsOn ? "On" : "Off"
        }

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView(arrangedSubviews: [
            sectionLabel("Custom controls — touch-only, not keyboard-focusable"),
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
}
