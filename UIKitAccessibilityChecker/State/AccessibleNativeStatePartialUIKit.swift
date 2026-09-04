import UIKit

/// STATE — Partial tier, native controls.
///
/// Same nine native controls, all still fully usable by sight. The bug in
/// every case is that a developer *overrode* the state UIKit was already
/// giving for free with a hardcoded string set once at launch, or drove a
/// state visually (alpha, tint, a private Bool) instead of through the
/// real property. VoiceOver announces a state — it is just the wrong one,
/// or a frozen snapshot of the initial one.
///
/// This tier is the interesting one for a state ruleset: nothing is
/// missing outright, so a checker that only looks for "is accessibilityValue
/// nil?" passes all of it.
///
/// Element-by-element:
///   1. UISwitch                — accessibilityValue frozen at "Off"
///   2. UISlider                — accessibilityValue frozen at "50 percent"
///   3. UIStepper               — accessibilityValue frozen at "1"
///   4. UISegmentedControl      — accessibilityValue overwritten, hides selection
///   5. UIPageControl           — accessibilityValue frozen at "page 1 of 5"
///   6. UIButton toggle         — custom Bool + image swap, isSelected never set
///   7. UIButton disabled       — greyed with alpha, isEnabled still true
///   8. UIProgressView          — accessibilityValue frozen at "0 percent"
///   9. UIActivityIndicatorView — spins with no label, value, or announcement
final class AccessibleNativeStatePartialViewController: UIViewController {

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
    /// The custom flag that replaces `isSelected` — this is the bug.
    private var isFavorite = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Native State (Partial)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 1. Switch — the developer "helpfully" added a value string.
        // Assigning accessibilityValue REPLACES UIKit's live on/off state,
        // and the valueChanged action below never refreshes it, so this
        // now announces "Off" forever, including when it's on.
        notificationsSwitch.isOn = true
        notificationsSwitch.accessibilityLabel = "Enable notifications"
        notificationsSwitch.accessibilityValue = "Off"
        notificationsSwitch.addTarget(self, action: #selector(notificationsSwitchChanged), for: .valueChanged)

        // 2. Slider — value set once at build time and never refreshed in
        // the valueChanged handler. Dragging to 90% still announces 50.
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 0.5
        volumeSlider.accessibilityLabel = "Volume"
        volumeSlider.accessibilityValue = "50 percent"

        // 3. Stepper — same pattern. The visible label updates, the
        // announced value does not.
        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = 10
        quantityStepper.value = 1
        quantityValueLabel.text = "\(quantity)"
        quantityStepper.accessibilityLabel = "Quantity"
        quantityStepper.accessibilityValue = "1"
        quantityStepper.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.quantity = Int(self.quantityStepper.value)
            // Bug: quantityStepper.accessibilityValue is never updated here.
        }, for: .valueChanged)

        // 4. Segmented control — overwriting accessibilityValue with a
        // description of the control wipes out the "selected, 2 of 3"
        // that UIKit was already announcing.
        colorSegmentedControl.selectedSegmentIndex = 1
        colorSegmentedControl.accessibilityLabel = "Favorite color"
        colorSegmentedControl.accessibilityValue = "Choose a color"

        // 5. Page control — frozen at page 1 while the carousel moves.
        pageControl.numberOfPages = 5
        pageControl.currentPage = 1
        pageControl.accessibilityLabel = "Onboarding pages"
        pageControl.accessibilityValue = "page 1 of 5"

        // 6. Toggle button — driven by a private Bool and an image swap.
        // The star visibly fills, but isSelected is never touched, so the
        // .selected trait never appears and VoiceOver announces the same
        // thing in both states.
        favoriteToggleButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteToggleButton.accessibilityLabel = "Mark as favorite"
        favoriteToggleButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.isFavorite.toggle()
            self.favoriteToggleButton.setImage(
                UIImage(systemName: self.isFavorite ? "star.fill" : "star"),
                for: .normal
            )
        }, for: .touchUpInside)

        // 7. Disabled button — dimmed visually only. isEnabled stays true,
        // so no .notEnabled trait, no "dimmed" announcement, and the tap
        // target still activates (doing nothing).
        submitButton.setTitle("Submit", for: .normal)
        submitButton.alpha = 0.4
        submitButton.accessibilityLabel = "Submit"

        // 8. Progress — a background download drives `progress`, but the
        // announced value was captured before the download started.
        downloadProgressView.progress = 0.4
        downloadProgressView.accessibilityLabel = "Download progress"
        downloadProgressView.accessibilityValue = "0 percent"

        // 9. Activity indicator — left entirely at UIKit's defaults. It is
        // not an accessibility element, so the busy state is invisible:
        // VoiceOver users hear nothing start, nothing finish.
        loadingToggleButton.setTitle("Start Loading", for: .normal)
        loadingToggleButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            if self.loadingIndicator.isAnimating {
                self.loadingIndicator.stopAnimating()
                self.loadingToggleButton.setTitle("Start Loading", for: .normal)
            } else {
                self.loadingIndicator.startAnimating()
                self.loadingToggleButton.setTitle("Stop Loading", for: .normal)
            }
            // Bug: no accessibilityValue update, no announcement.
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

    // MARK: - Actions

    @objc private func notificationsSwitchChanged() {
        // Bug: accessibilityValue is never touched here — it stays at
        // whatever was assigned once during buildLayout().
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
