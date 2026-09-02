import UIKit

/// Worst-case tier: every gap from Partial remains, and several controls
/// now report state that is actively WRONG rather than merely absent —
/// permanently inverted values, a selected trait pinned to the wrong item,
/// an enabled-sounding button that does nothing, and a busy state that
/// announces completion the moment work starts. Wrong state is worse than
/// missing state: missing state makes a user look harder, wrong state
/// makes them stop looking. Deliberately broken; reference only.
///
/// UIKit equivalent of AccessibleStateFail.swift (SwiftUI).

// MARK: - Selected: pinned to the wrong chip

private final class FailFilterChipsRow: UIView {
    private let filters = ["All", "Unread", "Flagged"]
    private var buttons: [UIButton] = []
    private(set) var selectedFilter = "Unread"

    init() {
        super.init(frame: .zero)
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])

        for (index, filter) in filters.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(filter, for: .normal)
            button.tag = index
            button.layer.cornerRadius = 14
            button.clipsToBounds = true
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
            button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
            buttons.append(button)
        }
        refresh()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func tapped(_ sender: UIButton) {
        selectedFilter = filters[sender.tag]
        refresh()
    }

    private func refresh() {
        for (index, button) in buttons.enumerated() {
            let isSelected = filters[index] == selectedFilter
            button.backgroundColor = isSelected
                ? UIColor.tintColor.withAlphaComponent(0.2)
                : .systemGray6
            // Actively wrong: the first chip is always marked selected
            // regardless of the real selection, so VoiceOver and the
            // screen disagree about which filter is active.
            if index == 0 {
                button.accessibilityTraits.insert(.selected)
            } else {
                button.accessibilityTraits.remove(.selected)
            }
            // FIX — derive from the actual state:
            // if isSelected { button.accessibilityTraits.insert(.selected) }
            // else { button.accessibilityTraits.remove(.selected) }
        }
    }
}

// MARK: - Expanded / collapsed: hidden from VoiceOver entirely

private final class FailDisclosureRow: UIControl {
    private let titleLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let detailLabel = UILabel()
    private(set) var isExpanded = false

    init(title: String, detail: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        detailLabel.text = detail
        detailLabel.font = .preferredFont(forTextStyle: .footnote)
        detailLabel.numberOfLines = 0
        detailLabel.isHidden = true

        let header = UIStackView(arrangedSubviews: [titleLabel, UIView(), chevron])
        header.axis = .horizontal
        header.alignment = .center

        let stack = UIStackView(arrangedSubviews: [header, detailLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addTarget(self, action: #selector(toggle), for: .touchUpInside)

        // Actively wrong: the whole control is removed from the
        // accessibility tree, so the collapsed content below it can never
        // be revealed by a VoiceOver user.
        accessibilityElementsHidden = true
        // FIX — expose it as a button and report its state:
        // isAccessibilityElement = true
        // accessibilityTraits = .button
        // accessibilityLabel = title
        // accessibilityValue = isExpanded ? "Expanded" : "Collapsed"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isExpanded.toggle()
        detailLabel.isHidden = !isExpanded
        UIView.animate(withDuration: 0.2) {
            self.chevron.transform = self.isExpanded
                ? CGAffineTransform(rotationAngle: .pi / 2)
                : .identity
        }
    }
}

// MARK: - Checked: permanently inverted

private final class FailCheckboxRow: UIControl {
    private let icon = UIImageView()
    private let label = UILabel()
    private(set) var isChecked = false

    init(title: String) {
        super.init(frame: .zero)
        label.text = title
        icon.contentMode = .scaleAspectFit
        icon.image = UIImage(systemName: "square")

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22)
        ])

        addTarget(self, action: #selector(toggle), for: .touchUpInside)

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        // Actively wrong: the ternary is backwards from the very first
        // frame. A user who has NOT agreed is told they have — a consent
        // checkbox lying about consent.
        accessibilityValue = isChecked ? "Not checked" : "Checked"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isChecked.toggle()
        icon.image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
        accessibilityValue = isChecked ? "Not checked" : "Checked"
        // FIX — accessibilityValue = isChecked ? "Checked" : "Not checked"
    }
}

// MARK: - Invalid: error suppressed

private final class FailValidatedEmailField: UIView {
    let textField = UITextField()
    private(set) var currentError: String?
    var onChange: (() -> Void)?

    init() {
        super.init(frame: .zero)
        // Actively wrong: no placeholder, no accessibilityLabel — the
        // field is unlabeled.
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        // Actively wrong: the error text is computed in textChanged() below
        // but never rendered anywhere, and the value is overwritten with a
        // placeholder that erases both the entered text and the error.
        textField.accessibilityValue = "Empty"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func textChanged() {
        let text = textField.text ?? ""
        currentError = (text.contains("@") || text.isEmpty) ? nil : "Enter a valid email address"
        // Bug: currentError is computed but never surfaced anywhere — no
        // label, no accessibilityValue update, nothing.
        onChange?()
    }
}

// MARK: - Current: every step marked current

private final class FailStepTrackerRow: UIView {
    private let steps: [String]
    private var buttons: [UIButton] = []
    private(set) var currentStep: Int

    init(steps: [String], currentStep: Int) {
        self.steps = steps
        self.currentStep = currentStep
        super.init(frame: .zero)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        for (index, title) in steps.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .preferredFont(forTextStyle: .caption1)
            button.tag = index
            button.addTarget(self, action: #selector(selectStep(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
            buttons.append(button)
        }
        refresh()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func selectStep(_ sender: UIButton) {
        currentStep = sender.tag
        refresh()
    }

    private func refresh() {
        for (index, button) in buttons.enumerated() {
            let isCurrent = index == currentStep
            button.titleLabel?.font = isCurrent
                ? .boldSystemFont(ofSize: 12)
                : .systemFont(ofSize: 12)
            // Actively wrong: every step claims to be selected, which is
            // indistinguishable from none of them being selected — and
            // also suggests a multi-select control.
            button.accessibilityTraits.insert(.selected)
            // FIX:
            // if isCurrent { button.accessibilityTraits.insert(.selected) }
            // else { button.accessibilityTraits.remove(.selected) }
            // button.accessibilityValue = "Step \(index + 1) of \(steps.count)"
        }
    }
}

// MARK: - Screen

final class AccessibleStateFailViewController: UIViewController {

    private let filterChips = FailFilterChipsRow()
    private let disclosureRow = FailDisclosureRow(
        title: "Shipping details",
        detail: "Delivered in 5–7 business days."
    )
    private let checkboxRow = FailCheckboxRow(title: "I agree to the Terms of Service")
    private let continueButton = UIButton(type: .system)
    private let submitButton = UIButton(type: .system)
    private let submitSpinner = UIActivityIndicatorView(style: .medium)
    private let emailField = FailValidatedEmailField()
    private let playButton = UIButton(type: .system)
    private let stepTracker = FailStepTrackerRow(
        steps: ["Cart", "Shipping", "Payment", "Review"],
        currentStep: 2
    )

    private var isSubmitting = false
    private var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildLayout()
        wireActions()

        // Actively wrong: a fixed label that stops being true the instant
        // playback starts, and no value to correct it.
        playButton.accessibilityLabel = "Play"
        updatePlayImage()
    }

    private func wireActions() {
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
    }

    private func buildLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 28
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        // Icon-only trigger with no label either — reads as a bare
        // "activity indicator" with no action attached.
        submitButton.addSubview(submitSpinner)
        submitSpinner.isUserInteractionEnabled = false
        submitSpinner.startAnimating()
        submitSpinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitSpinner.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor),
            submitSpinner.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 44),
            submitButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        contentStack.addArrangedSubview(section(filterChips))
        contentStack.addArrangedSubview(section(disclosureRow))
        contentStack.addArrangedSubview(section(checkboxRow))
        contentStack.addArrangedSubview(section(continueButton))
        contentStack.addArrangedSubview(section(submitButton))
        contentStack.addArrangedSubview(section(emailField))
        contentStack.addArrangedSubview(section(playButton))
        contentStack.addArrangedSubview(section(stepTracker))
    }

    private func section(_ content: UIView) -> UIView {
        // No section headers here — mirrors the Fail source, which drops
        // the section titles along with everything else.
        content
    }

    // MARK: Disabled — inert but announced as available

    @objc private func continueTapped() {
        // Guarded internally; nothing happens, silently.
    }
    // Actively wrong: the button is dead code for most of the form's life,
    // yet reports as a normal enabled control. No dimmed trait, no hint,
    // no feedback on activation.
    // FIX — continueButton.isEnabled = isFormValid, plus an
    // accessibilityHint explaining what would enable it.

    // MARK: Busy — announces the opposite of what happened

    @objc private func submitTapped() {
        isSubmitting = true
        // Actively wrong: fired at the START of the work, so the user is
        // told it finished while it's still in flight — and gets nothing
        // when it actually does.
        UIAccessibility.post(notification: .announcement, argument: "Submitted successfully")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isSubmitting = false
        }
    }

    // MARK: Playing / Paused — static label, no state at all

    @objc private func playTapped() {
        isPlaying.toggle()
        updatePlayImage()
        // No accessibilityLabel/Value update here at all.
    }

    private func updatePlayImage() {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
