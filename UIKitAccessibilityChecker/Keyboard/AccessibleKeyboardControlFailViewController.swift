import UIKit

/// KEYBOARD — Fail: interactive control cannot receive keyboard focus (BB41036).
///
/// Elements covered (2): a stepper and a slider that work by touch but refuse
/// keyboard focus (`canBecomeFocused` is false), so Tab and Full Keyboard
/// Access skip them -> BB41036.
final class AccessibleKeyboardControlFailViewController: UIViewController {

    private final class UnfocusableStepper: UIStepper {
        override var canBecomeFocused: Bool { false }
    }

    private final class UnfocusableSlider: UISlider {
        override var canBecomeFocused: Bool { false }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Keyboard Control – Fail"
        view.backgroundColor = .systemBackground

        let toggle = UnfocusableStepper()
        toggle.accessibilityLabel = "Quantity"
        let slider = UnfocusableSlider()
        slider.accessibilityLabel = "Volume"

        let stack = UIStackView(arrangedSubviews: [toggle, slider])
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            slider.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
    }
}
