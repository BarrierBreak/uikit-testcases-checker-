import UIKit

/// Demonstrates ACCESSIBLE STATE, as opposed to accessible NAME or ROLE.
/// State tells VoiceOver what condition a control is CURRENTLY in —
/// selected, expanded, checked, disabled, busy, invalid, playing — as
/// distinct from what it's called or what kind of control it is.
///
/// The recurring failure this file guards against: the state is conveyed
/// visually (a highlight, a chevron rotation, a red border, a dimmed
/// button) but never surfaced as an `accessibilityValue`, a trait, or an
/// announcement, so a VoiceOver user hears an identical string whether the
/// control is on or off.
///
/// UIKit equivalent of AccessibleStatePass.swift (SwiftUI).

// MARK: - Selected: Filter Chips

private final class PassFilterChipsRow: UIView {
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
            // The background tint is the ONLY visual cue. .selected is what
            // carries that same information to VoiceOver ("Unread,
            // selected, button"), and it's driven by the real selection
            // state, not by position.
            if isSelected {
                button.accessibilityTraits.insert(.selected)
            } else {
                button.accessibilityTraits.remove(.selected)
            }
        }
    }
}

// MARK: - Expanded / Collapsed: Disclosure Row

private final class PassDisclosureRow: UIControl {
    private let titleLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let detailLabel = UILabel()
    private(set) var isExpanded = false

    init(title: String, detail: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        detailLabel.text = detail
        detailLabel.font = .preferredFont(forTextStyle: .footnote)
        detailLabel.textColor = .secondaryLabel
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

        // Exposed as one accessibility element with a button role.
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        updateAccessibility()
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
        updateAccessibility()
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }

    private func updateAccessibility() {
        // iOS exposes no dedicated expanded/collapsed trait, so the state
        // rides on accessibilityValue. Without it, the rotating chevron is
        // invisible to VoiceOver.
        accessibilityValue = isExpanded ? "Expanded" : "Collapsed"
        accessibilityHint = isExpanded ? "Double tap to collapse" : "Double tap to expand"
    }
}

// MARK: - Checked: Checkbox

private final class PassCheckboxRow: UIControl {
    private let icon = UIImageView()
    private let label = UILabel()
    private(set) var isChecked = false

    init(title: String) {
        super.init(frame: .zero)
        label.text = title
        icon.contentMode = .scaleAspectFit

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
        refresh()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isChecked.toggle()
        refresh()
    }

    private func refresh() {
        icon.image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
        // A native switch would announce "on"/"off" for free — a hand-built
        // checkbox has to state it explicitly, and keep it in sync on
        // every toggle.
        accessibilityValue = isChecked ? "Checked" : "Not checked"
    }
}

// MARK: - Invalid: Email Field

private final class PassValidatedEmailField: UIView {
    let textField = UITextField()
    private let errorLabel = UILabel()
    private(set) var currentError: String?
    var onChange: (() -> Void)?

    init() {
        super.init(frame: .zero)
        textField.placeholder = "Email address"
        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.textContentType = .emailAddress
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        errorLabel.font = .preferredFont(forTextStyle: .footnote)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        // This text is already carried by the field's accessibilityValue —
        // don't make VoiceOver users hear it twice.
        errorLabel.isAccessibilityElement = false

        let stack = UIStackView(arrangedSubviews: [textField, errorLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // "Required" belongs in the label; the error text belongs in the
        // value so it's re-read whenever the field regains focus.
        textField.accessibilityLabel = "Email address, required"
        updateAccessibilityValue()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func textChanged() {
        let text = textField.text ?? ""
        let wasValid = currentError == nil
        currentError = (text.contains("@") || text.isEmpty) ? nil : "Enter a valid email address"
        errorLabel.text = currentError
        errorLabel.isHidden = currentError == nil
        layer.borderColor = currentError == nil ? UIColor.clear.cgColor : UIColor.systemRed.cgColor
        updateAccessibilityValue()

        // Announce the transition into an error state — the red border is
        // purely visual otherwise.
        if wasValid, let error = currentError {
            UIAccessibility.post(notification: .announcement, argument: error)
        }
        onChange?()
    }

    private func updateAccessibilityValue() {
        textField.accessibilityValue = currentError ?? (textField.text ?? "")
    }
}

// MARK: - Current: Step Tracker

private final class PassStepTrackerRow: UIView {
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
            button.tintColor = isCurrent ? .tintColor : .secondaryLabel

            // Position is state too — bold/colour styling is reflected in
            // the accessibility tree, not just on screen.
            if isCurrent {
                button.accessibilityTraits.insert(.selected)
            } else {
                button.accessibilityTraits.remove(.selected)
            }
            button.accessibilityValue = "Step \(index + 1) of \(steps.count)"
        }
    }
}

// MARK: - Screen

final class AccessibleStatePassViewController: UIViewController {

    private let filterChips = PassFilterChipsRow()
    private let disclosureRow = PassDisclosureRow(
        title: "Shipping details",
        detail: "Delivered in 5–7 business days."
    )
    private let checkboxRow = PassCheckboxRow(title: "I agree to the Terms of Service")
    private let continueButton = UIButton(type: .system)
    private let submitButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let emailField = PassValidatedEmailField()
    private let playButton = UIButton(type: .system)
    private let stepTracker = PassStepTrackerRow(
        steps: ["Cart", "Shipping", "Payment", "Review"],
        currentStep: 2
    )

    private var isSubmitting = false
    private var isPlaying = false

    private var isFormValid: Bool {
        !(emailField.textField.text ?? "").isEmpty && emailField.currentError == nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accessible State"
        view.backgroundColor = .systemBackground
        buildLayout()
        wireActions()
        refreshFormDependentUI()
        refreshSubmitButton()
        refreshPlayButton()
    }

    private func wireActions() {
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        emailField.onChange = { [weak self] in self?.refreshFormDependentUI() }

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

        activityIndicator.isAccessibilityElement = false // state lives on the button, not the spinner
        activityIndicator.hidesWhenStopped = true
        let submitRow = UIStackView(arrangedSubviews: [submitButton, activityIndicator])
        submitRow.axis = .horizontal
        submitRow.spacing = 8

        contentStack.addArrangedSubview(section("Selected", filterChips))
        contentStack.addArrangedSubview(section("Expanded / Collapsed", disclosureRow))
        contentStack.addArrangedSubview(section("Checked", checkboxRow))
        contentStack.addArrangedSubview(section("Disabled", continueButton))
        contentStack.addArrangedSubview(section("Busy", submitRow))
        contentStack.addArrangedSubview(section("Invalid", emailField))
        contentStack.addArrangedSubview(section("Playing / Paused", playButton))
        contentStack.addArrangedSubview(section("Current", stepTracker))
    }

    private func section(_ title: String, _ content: UIView) -> UIView {
        let header = UILabel()
        header.text = title
        header.font = .preferredFont(forTextStyle: .headline)
        let stack = UIStackView(arrangedSubviews: [header, content])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    // MARK: Disabled

    @objc private func continueTapped() {
        guard isFormValid else { return }
        // proceed to shipping
    }

    private func refreshFormDependentUI() {
        // isEnabled automatically adds/removes the .notEnabled trait —
        // VoiceOver announces "Continue, dimmed, button" for free. Never
        // fake this with .alpha alone.
        continueButton.isEnabled = isFormValid
        continueButton.accessibilityHint = isFormValid
            ? "Proceeds to shipping"
            : "Unavailable until a valid email address is entered"
    }

    // MARK: Busy

    @objc private func submitTapped() {
        guard !isSubmitting else { return }
        isSubmitting = true
        refreshSubmitButton()
        // A spinner appearing does not move VoiceOver focus, so the state
        // change must be announced.
        UIAccessibility.post(notification: .announcement, argument: "Submitting, please wait")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isSubmitting = false
            self?.refreshSubmitButton()
            UIAccessibility.post(notification: .announcement, argument: "Submitted successfully")
        }
    }

    private func refreshSubmitButton() {
        submitButton.setTitle(isSubmitting ? "Submitting…" : "Submit", for: .normal)
        submitButton.isEnabled = !isSubmitting
        submitButton.accessibilityLabel = "Submit"
        submitButton.accessibilityValue = isSubmitting ? "Busy" : ""
        isSubmitting ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    // MARK: Playing / Paused

    @objc private func playTapped() {
        isPlaying.toggle()
        refreshPlayButton()
    }

    private func refreshPlayButton() {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: imageName), for: .normal)
        // The LABEL describes the action, the VALUE describes the current
        // state — keeping both stable avoids the classic "is 'Play' what
        // it does or what it's doing?" ambiguity.
        playButton.accessibilityLabel = isPlaying ? "Pause" : "Play"
        playButton.accessibilityValue = isPlaying ? "Playing" : "Paused"
    }
}
