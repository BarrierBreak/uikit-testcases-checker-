import UIKit

/// STATE — Fail tier, native controls.
///
/// Worst case. Partial announced a stale state; this file announces a
/// state that actively contradicts what is on screen, or suppresses the
/// element carrying the state altogether. A VoiceOver user acting on
/// these announcements makes the opposite decision to a sighted user.
/// Deliberately broken; reference only.
///
/// Element-by-element:
///   1. UISwitch                — value INVERTED against isOn
///   2. UISlider                — value reports the max, not the current
///   3. UIStepper               — isAccessibilityElement = false, state gone
///   4. UISegmentedControl      — .selected forced onto ALL segments
///   5. UIPageControl           — value reports the last page always
///   6. UIButton toggle         — .selected hardcoded on, never cleared
///   7. UIButton disabled       — .notEnabled on a genuinely ENABLED button
///   8. UIProgressView          — announces "complete" at 40%
///   9. UIActivityIndicatorView — announces "Idle" while spinning
final class AccessibleNativeStateFailViewController: UIViewController {

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
        title = "Native State (Fail)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 1. Switch — the value string is derived from the WRONG branch of
        // the condition. On reads as "Off", off reads as "On". Wired via
        // addTarget/#selector (rather than addAction) and .srcLine()-tagged
        // so the source-level state checks can see this exact control.
        notificationsSwitch.isOn = true
        notificationsSwitch.accessibilityLabel = "Enable notifications"
        notificationsSwitch.accessibilityValue = notificationsSwitch.isOn ? "Off" : "On"
        notificationsSwitch.addTarget(self, action: #selector(notificationsSwitchChanged), for: .valueChanged)

        // 2. Slider — reports maximumValue instead of value. Always
        // announces "100 percent" no matter where the thumb sits.
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 0.5
        volumeSlider.accessibilityLabel = "Volume"
        volumeSlider.accessibilityValue = "\(Int(volumeSlider.maximumValue * 100)) percent"

        // 3. Stepper — removed from the accessibility tree entirely, so
        // there is no element to carry the value and no way to change it.
        // The count label beside it is also excluded.
        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = 10
        quantityStepper.value = 1
        quantityValueLabel.text = "\(quantity)"
        quantityStepper.isAccessibilityElement = false
        quantityValueLabel.isAccessibilityElement = false

        // 4. Segmented control — .selected is unioned onto the control
        // permanently, so every segment reports as chosen. Selection
        // becomes meaningless rather than merely absent.
        colorSegmentedControl.selectedSegmentIndex = 1
        colorSegmentedControl.accessibilityLabel = "Favorite color"
        colorSegmentedControl.accessibilityTraits.insert(.selected)
        colorSegmentedControl.accessibilityValue = "Red, Green, Blue, all selected"

        // 5. Page control — announces the final page regardless of where
        // the user actually is in the carousel.
        pageControl.numberOfPages = 5
        pageControl.currentPage = 1
        pageControl.accessibilityLabel = "Onboarding pages"
        pageControl.accessibilityValue = "page 5 of 5"

        // 6. Toggle button — .selected applied at build time and never
        // removed. The star renders empty; VoiceOver says "selected".
        favoriteToggleButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteToggleButton.accessibilityLabel = "Mark as favorite"
        favoriteToggleButton.accessibilityTraits = [.button, .selected]
        favoriteToggleButton.addAction(UIAction { _ in
            // Toggles nothing; the trait stays .selected forever.
        }, for: .touchUpInside)

        // 7. Disabled button — the reverse of the Partial bug. The button
        // is fully enabled and functional, but is announced as dimmed, so
        // VoiceOver users skip a control that actually works.
        submitButton.setTitle("Submit", for: .normal)
        submitButton.isEnabled = true
        submitButton.accessibilityLabel = "Submit"
        submitButton.accessibilityTraits.insert(.notEnabled)

        // 8. Progress — announces completion while the bar sits at 40%.
        downloadProgressView.progress = 0.4
        downloadProgressView.accessibilityLabel = "Download progress"
        downloadProgressView.accessibilityValue = "100 percent, complete"

        // 9. Activity indicator — opted into the tree with a value that is
        // the exact opposite of the visual state.
        loadingIndicator.isAccessibilityElement = true
        loadingIndicator.accessibilityLabel = "Transactions"
        loadingIndicator.accessibilityValue = "Idle"
        loadingToggleButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        loadingToggleButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.loadingIndicator.startAnimating()
            // Spins indefinitely; accessibilityValue stays "Idle".
        }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            notificationsSwitch,
            volumeSlider,
            hstack([quantityStepper, quantityValueLabel]),
            colorSegmentedControl,
            pageControl,
            favoriteToggleButton,
            submitButton,
            downloadProgressView,
            hstack([loadingIndicator, loadingToggleButton])
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        volumeSlider.widthAnchor.constraint(equalToConstant: 240).isActive = true
        downloadProgressView.widthAnchor.constraint(equalToConstant: 240).isActive = true
    }

    // MARK: - Actions

    @objc private func notificationsSwitchChanged() {
        notificationsSwitch.accessibilityValue = notificationsSwitch.isOn ? "Off" : "On"
    }

    private func hstack(_ views: [UIView]) -> UIView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }
}
