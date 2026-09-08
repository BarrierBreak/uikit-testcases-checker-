import UIKit

/// KEYBOARD — Pass tier, extras.
///
/// The keyboard concerns that are properties of the SCREEN rather than of
/// any one control: what order focus travels in, whether it can escape a
/// modal, whether it can be seen, whether shortcuts can be discovered,
/// whether a focused control is actually visible, and whether the software
/// keyboard hides what the user is typing into.
///
/// These are the ones that survive a control-by-control audit. Every widget
/// can be individually perfect while the screen as a whole is unusable
/// because focus jumps around, or lands somewhere off screen.
///
/// Elements covered (8) — all 8 require explicit keyboard work:
///   1. Focus order            — matches the visual reading order
///   2. Focus grouping         — related controls form one Tab stop
///   3. Modal focus trap       — focus contained, Escape exits
///   4. Focus indicator        — visible ring on every custom stop
///   5. Return-key chaining    — Return advances through the form
///   6. Escape to dismiss      — a consistent, discoverable way back
///   7. Scroll into view       — focused control scrolled on screen
///   8. Keyboard avoidance     — content lifted above the software keyboard
///   9. Alert dialog           — Return confirms the preferred action,
///                               Escape cancels, focus returns to trigger
///   10. Popover               — focus enters the popover and comes back
final class AccessibleKeyboardExtrasPassViewController: UIViewController {

    // MARK: - Controls

    private let scrollView = UIScrollView().srcLine()
    private let contentStack = UIStackView()

    private let firstNameField = UITextField().srcLine()
    private let lastNameField = UITextField().srcLine()
    private let emailField = UITextField().srcLine()
    private let submitButton = UIButton(type: .system).srcLine()

    private let priceMinusButton = UIButton(type: .system).srcLine()
    private let priceLabel = UILabel().srcLine()
    private let pricePlusButton = UIButton(type: .system).srcLine()
    private let priceGroup = UIStackView().srcLine()

    private let shortcutHintLabel = UILabel().srcLine()
    private let openPanelButton = UIButton(type: .system).srcLine()
    private let deleteAccountButton = UIButton(type: .system).srcLine()
    private let infoButton = UIButton(type: .system).srcLine()
    private let bottomField = UITextField().srcLine()

    private var price = 10 {
        didSet { priceLabel.text = "$\(price)" }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Keyboard Extras (Pass)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 1. Focus order. Views are added to the stack in the same order
        // they read on screen, so the focus system's geometric traversal
        // matches the visual order. Nothing is repositioned with transforms
        // or absolute frames that would desynchronise the two.
        firstNameField.placeholder = "First name"
        lastNameField.placeholder = "Last name"
        emailField.placeholder = "Email"
        [firstNameField, lastNameField, emailField].forEach {
            $0.borderStyle = .roundedRect
            $0.delegate = self
        }

        // 5. Return-key chaining. Return moves to the next field and
        // submits on the last one, so a keyboard user can complete the
        // form without reaching for Tab or a pointer.
        firstNameField.returnKeyType = .next
        lastNameField.returnKeyType = .next
        emailField.returnKeyType = .go

        submitButton.setTitle("Submit", for: .normal)
        submitButton.addAction(UIAction { [weak self] _ in
            self?.submit()
        }, for: .touchUpInside)

        // 2. Focus grouping. Minus, value and plus form one logical
        // control. A shared focusGroupIdentifier makes them a single Tab
        // stop with arrow keys moving inside, instead of three stops
        // interrupting the form.
        priceMinusButton.setTitle("−", for: .normal)
        priceMinusButton.accessibilityLabel = "Decrease price"
        priceMinusButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.price = max(self.price - 1, 0)
        }, for: .touchUpInside)

        pricePlusButton.setTitle("+", for: .normal)
        pricePlusButton.accessibilityLabel = "Increase price"
        pricePlusButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.price = min(self.price + 1, 100)
        }, for: .touchUpInside)

        priceLabel.text = "$\(price)"
        priceGroup.axis = .horizontal
        priceGroup.spacing = 12
        [priceMinusButton, priceLabel, pricePlusButton].forEach { priceGroup.addArrangedSubview($0) }
        priceGroup.focusGroupIdentifier = "com.example.price.stepper"

        // 4. Focus indicator. Custom stops get an explicit halo. Native
        // controls draw their own, so only the hand-built ones need this —
        // but they need it without exception, or focus becomes invisible
        // exactly where the user is least sure what is happening.
        priceGroup.focusEffect = UIFocusHaloEffect()

        // 6. Escape to dismiss, plus a discoverable shortcut list. The
        // discoverabilityTitle on each command is what puts it in the
        // hold-Command overlay; a shortcut nobody can find is not an
        // accessible alternative.
        shortcutHintLabel.text = "Hold Command to see keyboard shortcuts."
        shortcutHintLabel.font = .preferredFont(forTextStyle: .footnote)
        shortcutHintLabel.textColor = .secondaryLabel

        // 3. Modal focus trap. The panel below contains focus while open
        // and releases it on Escape. See KbdTrappingPanelViewController.
        openPanelButton.setTitle("Open Filter Panel", for: .normal)
        openPanelButton.addAction(UIAction { [weak self] _ in
            self?.presentPanel()
        }, for: .touchUpInside)

        // 9. Alert dialog. Two keys carry the whole interaction and both
        // must be bound to the right action: Return activates the
        // preferredAction, Escape activates the .cancel-style action.
        // Setting preferredAction to the SAFE choice matters, because
        // Return is the key a user presses without reading.
        deleteAccountButton.setTitle("Delete Account", for: .normal)
        deleteAccountButton.addAction(UIAction { [weak self] _ in
            self?.presentDeleteConfirmation()
        }, for: .touchUpInside)

        // 10. Popover. sourceView anchors it, the content inside is a real
        // focusable control rather than plain text, and focus returns to
        // the trigger on dismissal.
        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.accessibilityLabel = "More information"
        infoButton.addAction(UIAction { [weak self] _ in
            self?.presentInfoPopover()
        }, for: .touchUpInside)

        // 8. Keyboard avoidance. A field near the bottom would otherwise
        // sit behind the software keyboard once focused. keyboardLayoutGuide
        // ties the scroll view's bottom to the keyboard, so the content
        // lifts instead of being covered.
        bottomField.placeholder = "Notes (near the bottom)"
        bottomField.borderStyle = .roundedRect
        bottomField.delegate = self

        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 400).isActive = true

        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        [
            row(title: "Focus Order", control: vstack([firstNameField, lastNameField, emailField, submitButton])),
            row(title: "Focus Group", control: priceGroup),
            row(title: "Modal Focus Trap", control: openPanelButton),
            row(title: "Alert Dialog", control: deleteAccountButton),
            row(title: "Popover", control: infoButton),
            row(title: "Discoverable Shortcuts", control: shortcutHintLabel),
            row(title: "Scroll Into View", control: spacer),
            row(title: "Keyboard Avoidance", control: bottomField)
        ].forEach { contentStack.addArrangedSubview($0) }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Bottom pinned to the keyboard, not the safe area.
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    // MARK: - 7. Scroll into view

    /// A control can be focused while sitting outside the visible bounds of
    /// its scroll view. Scrolling it into view on every focus change is
    /// what keeps focus and sight in agreement.
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        guard let next = context.nextFocusedView else { return }
        let frameInScroll = next.convert(next.bounds, to: scrollView)
        scrollView.scrollRectToVisible(frameInScroll.insetBy(dx: 0, dy: -24), animated: true)
    }

    // MARK: - Key commands

    override var canBecomeFirstResponder: Bool { true }

    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(title: "Submit form",
                         action: #selector(submitFromKeyboard),
                         input: "\r",
                         modifierFlags: .command),
            UIKeyCommand(title: "Clear form",
                         action: #selector(clearForm),
                         input: "k",
                         modifierFlags: .command)
        ]
    }

    @objc private func submitFromKeyboard() { submit() }

    @objc private func clearForm() {
        [firstNameField, lastNameField, emailField, bottomField].forEach { $0.text = "" }
    }

    private func submit() { /* submit */ }

    private func presentDeleteConfirmation() {
        let alert = UIAlertController(
            title: "Delete your account?",
            message: "This cannot be undone.",
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.returnFocus(to: self?.deleteAccountButton)
        }
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.returnFocus(to: self?.deleteAccountButton)
        }
        alert.addAction(delete)
        alert.addAction(cancel)
        // Return activates the non-destructive action. Escape maps to the
        // .cancel-style action automatically, so both keys are safe.
        alert.preferredAction = cancel
        present(alert, animated: true)
    }

    private func presentInfoPopover() {
        let contentVC = UIViewController()
        contentVC.view.backgroundColor = .secondarySystemBackground

        let label = UILabel().srcLine()
        label.text = "This feature syncs your data across devices."
        label.numberOfLines = 0
        // A focusable control inside the popover, so focus has somewhere
        // to land. A popover of pure static text gives the focus system
        // nothing to move to.
        let learnMoreButton = UIButton(type: .system).srcLine()
        learnMoreButton.setTitle("Learn more", for: .normal)

        let stack = UIStackView(arrangedSubviews: [label, learnMoreButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentVC.view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentVC.view.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentVC.view.bottomAnchor, constant: -16)
        ])

        contentVC.preferredContentSize = CGSize(width: 280, height: 120)
        contentVC.modalPresentationStyle = .popover
        if let popover = contentVC.popoverPresentationController {
            popover.sourceView = infoButton
            popover.sourceRect = infoButton.bounds
            popover.delegate = self
        }
        present(contentVC, animated: true)
    }

    private func returnFocus(to view: UIView?) {
        view?.becomeFirstResponder()
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }

    private func presentPanel() {
        let panel = KbdTrappingPanelViewController()
        panel.modalPresentationStyle = .formSheet
        panel.onDismiss = { [weak self] in
            // Focus returns to the button that opened the panel.
            self?.openPanelButton.becomeFirstResponder()
            self?.setNeedsFocusUpdate()
            self?.updateFocusIfNeeded()
        }
        present(panel, animated: true)
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

    private func vstack(_ views: [UIView]) -> UIView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }
}

// MARK: - 5. Return-key chaining

extension AccessibleKeyboardExtrasPassViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameField: lastNameField.becomeFirstResponder()
        case lastNameField:  emailField.becomeFirstResponder()
        case emailField:     emailField.resignFirstResponder(); submit()
        default:             textField.resignFirstResponder()
        }
        return false
    }
}

// MARK: - 10. Popover focus return

extension AccessibleKeyboardExtrasPassViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Stay a popover on compact widths instead of becoming a full
        // sheet, so the anchor relationship and the focus return hold.
        .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        returnFocus(to: infoButton)
    }
}

// MARK: - 3. Modal focus trap

/// Focus is contained inside this panel while it is open — the focus group
/// identifier plus a modal presentation stop Tab reaching the screen
/// underneath — and Escape provides a guaranteed way out.
final class KbdTrappingPanelViewController: UIViewController {

    var onDismiss: (() -> Void)?
    private let closeButton = UIButton(type: .system).srcLine()
    private let applyButton = UIButton(type: .system).srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.accessibilityViewIsModal = true
        view.focusGroupIdentifier = "com.example.filter.panel"

        closeButton.setTitle("Close", for: .normal)
        closeButton.addAction(UIAction { [weak self] _ in self?.close() }, for: .touchUpInside)

        applyButton.setTitle("Apply Filters", for: .normal)

        let hint = UILabel().srcLine()
        hint.text = "Press Escape to close."
        hint.font = .preferredFont(forTextStyle: .footnote)
        hint.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [applyButton, closeButton, hint])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override var canBecomeFirstResponder: Bool { true }

    /// Focus starts inside the panel rather than wherever it happened to be.
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        [applyButton]
    }

    override var keyCommands: [UIKeyCommand]? {
        [UIKeyCommand(title: "Close panel", action: #selector(close), input: UIKeyCommand.inputEscape)]
    }

    @objc private func close() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
}
