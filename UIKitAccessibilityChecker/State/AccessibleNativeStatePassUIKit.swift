import UIKit

/// STATE — Pass tier, native controls.
///
/// Every control here is a real UIKit control, so its *state* (on/off,
/// current value, current page, selected segment, selected, disabled) is
/// exposed to VoiceOver automatically and stays in sync without a single
/// line of manual accessibility code.
///
/// The one exception is `UIActivityIndicatorView`, which conveys "busy"
/// purely visually — it carries no state of its own and must be wired by
/// hand.
///
/// Elements covered (9):
///   1. UISwitch                  — on/off          (automatic)
///   2. UISlider                  — current value   (automatic)
///   3. UIStepper                 — current value   (automatic)
///   4. UISegmentedControl        — selected segment(automatic)
///   5. UIPageControl             — current page    (automatic)
///   6. UIButton (isSelected)     — selected        (automatic)
///   7. UIButton (isEnabled)      — disabled        (automatic)
///   8. UIProgressView            — percent complete(automatic)
///   9. UIActivityIndicatorView   — busy/idle       (MANUAL — see below)
///
/// Names (accessibilityLabel) are set here only so the announced state has
/// something to attach to; naming itself is covered by the AccessibleName*
/// files.
final class AccessibleNativeStatePassViewController: UIViewController {

    // MARK: - Controls

    private let notificationsSwitch = UISwitch().srcLine()
    private let volumeSlider = UISlider().srcLine()
    private let quantityStepper = UIStepper().srcLine()
    private let quantityValueLabel = UILabel().srcLine()
    private let colorSegmentedControl = UISegmentedControl(items: ["Red", "Green", "Blue"]).srcLine()
    private let pageControl = UIPageControl().srcLine()
    private let favoriteToggleButton = UIButton(type: .system).srcLine()
    private let submitButton = UIButton(type: .system).srcLine()
    private let downloadProgressView = UIProgressView(progressViewStyle: .default).srcLine()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium).srcLine()
    private let loadingToggleButton = UIButton(type: .system).srcLine()

    private var quantity = 1 {
        didSet { quantityValueLabel.text = "\(quantity)" }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Native State (Pass)"
        view.backgroundColor = .systemBackground
        buildLayout()
        configureAccessibility()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 1. Switch — UISwitch announces "on"/"off" as its value and
        // updates the moment isOn changes. Nothing to wire.
        notificationsSwitch.isOn = true

        // 2. Slider — UISlider announces its percentage continuously
        // while being adjusted, and exposes .adjustable automatically.
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 0.5

        // 3. Stepper — UIStepper announces its numeric value and reports
        // the new one after every increment/decrement.
        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = 10
        quantityStepper.value = 1
        quantityValueLabel.text = "\(quantity)"
        quantityStepper.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.quantity = Int(self.quantityStepper.value)
        }, for: .valueChanged)

        // 4. Segmented control — the selected segment is announced with
        // "selected" plus its position ("2 of 3"). Changing selection
        // re-announces automatically.
        colorSegmentedControl.selectedSegmentIndex = 1

        // 5. Page control — announces "page 2 of 5" and updates as
        // currentPage changes.
        pageControl.numberOfPages = 5
        pageControl.currentPage = 1

        // 6. Toggle-style button — driven by the REAL isSelected property,
        // which is what gives UIKit the .selected trait for free. A custom
        // Bool + image swap would not (see the Partial tier).
        favoriteToggleButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteToggleButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
        favoriteToggleButton.addAction(UIAction { [weak self] _ in
            self?.favoriteToggleButton.isSelected.toggle()
        }, for: .touchUpInside)

        // 7. Disabled button — driven by the REAL isEnabled property, so
        // UIKit adds .notEnabled and VoiceOver announces "dimmed".
        // Greying it out with alpha/tintColor alone would not.
        submitButton.setTitle("Submit", for: .normal)
        submitButton.isEnabled = false

        // 8. Determinate progress — UIProgressView exposes its percentage
        // as accessibilityValue and keeps it in sync with `progress`.
        downloadProgressView.progress = 0.4

        // 9. Activity indicator — the ONLY native control here with no
        // state of its own. Wired manually in configureAccessibility()
        // and updated in setLoading(_:).
        loadingToggleButton.setTitle("Start Loading", for: .normal)
        loadingToggleButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.setLoading(!self.loadingIndicator.isAnimating)
        }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            row(title: "Switch", control: notificationsSwitch),
            row(title: "Slider", control: volumeSlider),
            row(title: "Stepper", control: hstack([quantityStepper, quantityValueLabel])),
            row(title: "Segmented Control", control: colorSegmentedControl),
            row(title: "Page Control", control: pageControl),
            row(title: "Selected Toggle Button", control: favoriteToggleButton),
            row(title: "Disabled Button", control: submitButton),
            row(title: "Progress View", control: downloadProgressView),
            row(title: "Activity Indicator", control: hstack([loadingIndicator, loadingToggleButton]))
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Accessibility

    private func configureAccessibility() {
        notificationsSwitch.accessibilityLabel = "Enable notifications"
        volumeSlider.accessibilityLabel = "Volume"
        quantityStepper.accessibilityLabel = "Quantity"
        quantityValueLabel.isAccessibilityElement = false // stepper already announces the value
        colorSegmentedControl.accessibilityLabel = "Favorite color"
        pageControl.accessibilityLabel = "Onboarding pages"
        favoriteToggleButton.accessibilityLabel = "Mark as favorite"
        submitButton.accessibilityLabel = "Submit"
        submitButton.accessibilityHint = "Complete all required fields to enable"
        downloadProgressView.accessibilityLabel = "Download progress"

        // The manual case: a spinner is a purely visual busy state.
        // .updatesFrequently stops VoiceOver from interrupting itself
        // while the busy state is live.
        loadingIndicator.isAccessibilityElement = true
        loadingIndicator.accessibilityLabel = "Transactions"
        loadingIndicator.accessibilityTraits = .updatesFrequently
        loadingIndicator.accessibilityValue = "Idle"
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            loadingIndicator.accessibilityValue = "Loading"
            loadingToggleButton.setTitle("Stop Loading", for: .normal)
            UIAccessibility.post(notification: .announcement, argument: "Loading transactions")
        } else {
            loadingIndicator.stopAnimating()
            loadingIndicator.accessibilityValue = "Idle"
            loadingToggleButton.setTitle("Start Loading", for: .normal)
            UIAccessibility.post(notification: .announcement, argument: "Transactions loaded")
        }
    }

    // MARK: - Helpers

    private func row(title: String, control: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        let container = UIStackView(arrangedSubviews: [label, control])
        container.axis = .vertical
        container.spacing = 6
        container.alignment = .leading
        return container
    }

    private func hstack(_ views: [UIView]) -> UIView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }
}
