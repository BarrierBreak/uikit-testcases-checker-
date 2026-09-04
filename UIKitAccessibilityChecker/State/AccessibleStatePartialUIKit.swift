import UIKit

/// Partial tier: every control still has a correct NAME and a correct ROLE
/// — VoiceOver reads them and knows they're buttons — but the STATE is
/// either missing, stale, or conveyed in a way that only works for sighted
/// users. This is the hardest tier to catch in code review, because each
/// element already carries accessibility modifiers and looks "done".
///
/// The specific gaps, in order: chips have no .selected, the disclosure
/// row never reports expanded/collapsed, the checkbox has a hardcoded
/// value that never syncs, the disabled button is only visually dimmed,
/// the busy state is never announced, the error message is orphaned from
/// the field it describes, the play button's label and value contradict
/// each other, and the step tracker's current position is bold-only.
///
/// UIKit equivalent of AccessibleStatePartial.swift (SwiftUI).

// MARK: - Selected: trait omitted

private final class PartialFilterChipsRow: UIView {
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
            // Bug: role is right (UIButton already reports "button"), state
            // is absent. All three chips read "…, button" identically, so
            // the current filter is unknowable from VoiceOver alone.
        }
    }
}

// MARK: - Expanded / collapsed: no value

private final class PartialDisclosureRow: UIControl {
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

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        // Bug: no accessibilityValue set here or in toggle(). The rotating
        // chevron is the only expanded/collapsed cue, and rotation is not
        // exposed to the accessibility tree at all.
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
        // Still nothing tells VoiceOver the state changed.
    }
}

// MARK: - Checked: value never syncs

private final class PartialCheckboxRow: UIControl {
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
        icon.image = UIImage(systemName: "square")
        // Bug: hardcoded literal instead of reading isChecked. VoiceOver
        // insists it's unchecked even after the user checks it — worse
        // than silence, because it's confidently wrong and the user has no
        // reason to doubt it.
        accessibilityValue = "Not checked"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isChecked.toggle()
        icon.image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
        // accessibilityValue is never touched again after init.
    }
}

// MARK: - Invalid: error text is orphaned

private final class PartialValidatedEmailField: UIView {
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
        // Bug: no "required" note anywhere, and no custom accessibilityLabel.

        errorLabel.font = .preferredFont(forTextStyle: .footnote)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        // Bug: left as a normal, separate accessibility element. A user who
        // tabs straight from this field to the next control never hears
        // it — it's reachable only by swiping forward PAST the field.

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
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func textChanged() {
        let text = textField.text ?? ""
        currentError = (text.contains("@") || text.isEmpty) ? nil : "Enter a valid email address"
        errorLabel.text = currentError
        errorLabel.isHidden = currentError == nil
        layer.borderColor = currentError == nil ? UIColor.clear.cgColor : UIColor.systemRed.cgColor
        // Bug: no announcement, and accessibilityValue is left at its
        // UIKit default (just the raw typed text) — the error never
        // reaches the field itself, only the disconnected label below it.
        onChange?()
    }
}

// MARK: - Playing / Paused: state collapsed into the label

// (Handled directly on a plain UIButton in the view controller below.)

// MARK: - Current: bold-only

private final class PartialStepTrackerRow: UIView {
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
            // Bug: no .selected and no positional value. Weight and colour
            // carry the whole message, and neither reaches the
            // accessibility tree.
        }
    }
}

// MARK: - Screen

final class AccessibleStatePartialViewController: UIViewController {

    private let filterChips = PartialFilterChipsRow()
    private let disclosureRow = PartialDisclosureRow(
        title: "Shipping details",
        detail: "Delivered in 5–7 business days."
    ).srcLine()
    private let checkboxRow = PartialCheckboxRow(title: "I agree to the Terms of Service").srcLine()
    private let continueButton = UIButton(type: .system)
    private let submitButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let emailField = PartialValidatedEmailField()
    private let playButton = UIButton(type: .system)
    private let stepTracker = PartialStepTrackerRow(
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
        title = "Accessible State (Partial)"
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

    // MARK: Disabled — visual only

    @objc private func continueTapped() {
        guard isFormValid else { return }
        // proceed to shipping
    }

    private func refreshFormDependentUI() {
        // Bug: dimmed with alpha instead of .isEnabled = false. The button
        // still reports as fully enabled, so VoiceOver users double-tap an
        // active-sounding control and get nothing back, with no
        // explanation anywhere.
        continueButton.alpha = isFormValid ? 1.0 : 0.4
    }

    // MARK: Busy — never announced

    @objc private func submitTapped() {
        guard !isSubmitting else { return }
        isSubmitting = true
        refreshSubmitButton()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isSubmitting = false
            self?.refreshSubmitButton()
        }
        // Bug: no announcement on entering or leaving the busy state.
        // Focus stays on the button, so unless the user happens to
        // re-read it they never learn anything is in flight — or that
        // it finished.
    }

    private func refreshSubmitButton() {
        submitButton.setTitle(isSubmitting ? "Submitting…" : "Submit", for: .normal)
        isSubmitting ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    // MARK: Playing / Paused — state collapsed into the label

    @objc private func playTapped() {
        isPlaying.toggle()
        refreshPlayButton()
    }

    private func refreshPlayButton() {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: imageName), for: .normal)
        // Bug: the label flips to describe the STATE rather than the
        // action, and there's no value to disambiguate. The user hears
        // "Playing, button" and cannot tell whether double-tapping starts
        // or stops playback.
        playButton.accessibilityLabel = isPlaying ? "Playing" : "Paused"
    }
}
