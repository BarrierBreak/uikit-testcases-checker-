import UIKit

/// Reachable by Tab (overrides canBecomeFocused), but only wires .touchUpInside — not
/// .primaryActionTriggered — so a keyboard Select/Space press while focused does nothing,
/// unlike a tap. Demonstrates "focusable" and "keyboard-operable" being two different,
/// independently gettable-wrong requirements.
final class FocusableButNotActivatableChip: UIControl {
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

/// Not reachable by Tab at all — a plain UIView + gesture, same shape as
/// AccessibleKeyboardFailViewController's chip.
final class PartialInaccessibleChip: UIView {
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

final class AccessibleKeyboardPartialViewController: UIViewController {

    // Fully correct — reachable AND keyboard-activatable. Included so this screen shows the
    // full spectrum rather than only the two broken tiers.
    private let correctChip = KeyboardAccessibleChip().srcLine()
    // Reachable by Tab, but Space does nothing.
    private let deadEndChip = FocusableButNotActivatableChip().srcLine()
    // Not reachable by Tab at all.
    private let unreachableChip = PartialInaccessibleChip().srcLine()

    private var correctState = false
    private var deadEndState = false
    private var unreachableState = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accessible Keyboard (Partial)"
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
        correctChip.title = "Focusable and activatable"
        correctChip.accessibilityValue = "Off"
        correctChip.addTarget(self, action: #selector(toggleCorrect), for: [.touchUpInside, .primaryActionTriggered])

        deadEndChip.title = "Focusable, Space does nothing"
        deadEndChip.accessibilityValue = "Off"
        deadEndChip.addTarget(self, action: #selector(toggleDeadEnd), for: .touchUpInside)

        unreachableChip.title = "Not Tab-reachable at all"
        unreachableChip.accessibilityValue = "Off"
        unreachableChip.onTap = { [weak self] in
            guard let self else { return }
            self.unreachableState.toggle()
            self.unreachableChip.accessibilityValue = self.unreachableState ? "On" : "Off"
        }

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView(arrangedSubviews: [
            sectionLabel("Custom controls — mixed keyboard support"),
            correctChip,
            deadEndChip,
            unreachableChip
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

    @objc private func toggleCorrect() {
        correctState.toggle()
        correctChip.accessibilityValue = correctState ? "On" : "Off"
    }

    @objc private func toggleDeadEnd() {
        deadEndState.toggle()
        deadEndChip.accessibilityValue = deadEndState ? "On" : "Off"
    }
}
