import UIKit

/// UIKit equivalent of AccessibleNativeRolePass: uses the real native
/// controls (UISwitch, UISlider, UIStepper, UISegmentedControl) so role
/// and value are correct automatically, with no manual accessibility code
/// required for any of them.
final class AccessibleNativeRolePassViewController: UIViewController {

    private let notificationsSwitch = UISwitch().srcLine()
    private let volumeSlider = UISlider().srcLine()
    private let quantityStepper = UIStepper().srcLine()
    private let quantityLabel = UILabel()
    private let colorSegmentedControl = UISegmentedControl(items: ["Red", "Green", "Blue"]).srcLine()
    private let agreeSwitch = UISwitch().srcLine()

    private var quantity = 1 {
        didSet { quantityLabel.text = "\(quantity)" }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Native Controls"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        volumeSlider.value = 0.5
        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = 10
        quantityStepper.value = 1
        quantityLabel.text = "1"
        quantityStepper.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.quantity = Int(self.quantityStepper.value)
        }, for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [
            row(title: "Toggle", control: notificationsSwitch),
            row(title: "Slider", control: volumeSlider),
            row(title: "Stepper", control: hstack([quantityStepper, quantityLabel])),
            row(title: "Segmented Picker", control: colorSegmentedControl),
            row(title: "Checkbox-style Toggle", control: agreeSwitch)
        ])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // No accessibilityLabel/Traits/Value set anywhere below — UISwitch,
        // UISlider, UIStepper, and UISegmentedControl all expose correct
        // role and a live value by default. (Labels for WHAT each control
        // does still matter — see the AccessibleName* files — but the
        // ROLE itself needs nothing extra here.)
    }

    private func row(title: String, control: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        let container = UIStackView(arrangedSubviews: [label, control])
        container.axis = .vertical
        container.spacing = 6
        return container
    }

    private func hstack(_ views: [UIView]) -> UIView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }
}
