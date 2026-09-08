import UIKit

/// KEYBOARD — Partial tier, extras.
///
/// Every individual control on this screen is a native UIKit control that
/// focuses and operates correctly. Audited one widget at a time, this file
/// passes. Used with a keyboard, it does not: focus jumps around, lands off
/// screen, cannot be seen on the custom pieces, gets stuck in a panel, and
/// disappears behind the software keyboard.
///
/// This is the tier that argues for screen-level keyboard rules rather than
/// element-level ones.
///
/// Element-by-element:
///   1. Focus order         — visual order and view order disagree, so Tab
///                            jumps between unrelated parts of the form
///   2. Focus grouping      — a three-part stepper costs three Tab stops
///   3. Modal focus trap    — focus leaks out of the open panel to the
///                            screen behind it
///   4. Focus indicator     — custom stops have no focusEffect
///   5. Return-key chaining — Return dismisses the keyboard and stops; the
///                            user must find another way to each field
///   6. Escape to dismiss   — no Escape handler anywhere on the screen
///   7. Scroll into view    — focus moves off screen with no scrolling
///   8. Keyboard avoidance  — bottom field sits behind the keyboard
///   9. Alert dialog        — no preferredAction, so Return does nothing;
///                            focus is not returned to the trigger
///   10. Popover            — content is static text with no focusable
///                            control, so focus never enters it
final class AccessibleKeyboardExtrasPartialViewController: UIViewController {

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

    private let openPanelButton = UIButton(type: .system).srcLine()
    private let deleteAccountButton = UIButton(type: .system).srcLine()
    private let infoButton = UIButton(type: .system).srcLine()
    private let bottomField = UITextField().srcLine()

    private var price = 10 {
        didSet { priceLabel.text = "$\(price)" }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Keyboard Extras (Partial)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        firstNameField.placeholder = "First name"
        lastNameField.placeholder = "Last name"
        emailField.placeholder = "Email"
        [firstNameField, lastNameField, emailField, bottomField].forEach {
            $0.borderStyle = .roundedRect
        }
        bottomField.placeholder = "Notes (near the bottom)"

        // 5. Return-key chaining — returnKeyType is left at .default and
        // no delegate is set, so Return simply dismisses the keyboard.
        // Each field has to be reached separately, and on a form of any
        // length that is where keyboard users give up.

        submitButton.setTitle("Submit", for: .normal)

        // 2. Focus grouping — three separate focusable buttons and a label
        // for what is conceptually one control. No focusGroupIdentifier,
        // so Tab stops three times in the middle of the form.
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
        // Bug: no focusGroupIdentifier.
        // 4. Bug: no focusEffect on the group either.

        // 3. Modal focus trap — the panel is presented without
        // accessibilityViewIsModal, without a focus group, and without
        // preferredFocusEnvironments, so Tab walks straight out of the
        // open panel and into the form behind it.
        openPanelButton.setTitle("Open Filter Panel", for: .normal)
        openPanelButton.addAction(UIAction { [weak self] _ in
            self?.presentPanel()
        }, for: .touchUpInside)

        // 9. Alert — correctly titled, both actions correctly styled, but
        // preferredAction is never set. Return does nothing at all, so the
        // most common key for confirming a dialog is dead and the user
        // must tab to a button. Focus is also not returned afterwards.
        deleteAccountButton.setTitle("Delete Account", for: .normal)
        deleteAccountButton.addAction(UIAction { [weak self] _ in
            self?.presentDeleteConfirmation()
        }, for: .touchUpInside)

        // 10. Popover — anchored correctly and readable by pointer, but
        // its content is a single UILabel. There is no focusable element
        // inside, so focus has nowhere to go and stays on the screen
        // behind the popover.
        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.accessibilityLabel = "More information"
        infoButton.addAction(UIAction { [weak self] _ in
            self?.presentInfoPopover()
        }, for: .touchUpInside)

        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 400).isActive = true

        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        // 1. Focus order — the email field is visually placed between the
        // name fields using a negative-offset transform, but stays last in
        // the view hierarchy. Sighted order is first/last/email; focus
        // order is first/last, then jumps past Submit and back up. The
        // control order and the visual order have silently diverged.
        emailField.transform = CGAffineTransform(translationX: 0, y: -60)

        [
            row(title: "Focus Order", control: vstack([firstNameField, lastNameField, submitButton, emailField])),
            row(title: "Focus Group", control: priceGroup),
            row(title: "Modal Focus Trap", control: openPanelButton),
            row(title: "Alert Dialog", control: deleteAccountButton),
            row(title: "Popover", control: infoButton),
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
            // 8. Bug: pinned to the view's bottom rather than
            // keyboardLayoutGuide, so the software keyboard covers the
            // bottom field the moment it is focused.
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    // 7. Bug: no didUpdateFocus override, so a focused control below the
    // fold stays below the fold. The focus ring is drawn off screen and
    // the user is typing into something they cannot see.

    // 6. Bug: no keyCommands override, so there is no Escape handler and
    // no discoverable shortcut anywhere on this screen.

    private func presentDeleteConfirmation() {
        let alert = UIAlertController(
            title: "Delete your account?",
            message: "This cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // Bug: no preferredAction, so Return is inert. Escape still works
        // because of the .cancel style, which is why this reads as "mostly
        // fine" in casual testing.
        present(alert, animated: true)
    }

    private func presentInfoPopover() {
        let contentVC = UIViewController()
        contentVC.view.backgroundColor = .secondarySystemBackground

        let label = UILabel().srcLine()
        label.text = "This feature syncs your data across devices."
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        contentVC.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentVC.view.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: contentVC.view.bottomAnchor, constant: -16)
        ])

        contentVC.preferredContentSize = CGSize(width: 260, height: 100)
        contentVC.modalPresentationStyle = .popover
        if let popover = contentVC.popoverPresentationController {
            popover.sourceView = infoButton
            popover.sourceRect = infoButton.bounds
        }
        // Bug: no focusable content inside, and no delegate to restore
        // focus when the popover closes.
        present(contentVC, animated: true)
    }

    private func presentPanel() {
        let panel = PartialPanelViewController()
        panel.modalPresentationStyle = .formSheet
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

/// Presented modally, but nothing contains focus inside it and nothing
/// provides a keyboard route out.
final class PartialPanelViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Bug: no accessibilityViewIsModal, no focusGroupIdentifier, no
        // preferredFocusEnvironments, no Escape command.

        let closeButton = UIButton(type: .system).srcLine()
        closeButton.setTitle("Close", for: .normal)
        closeButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)

        let applyButton = UIButton(type: .system).srcLine()
        applyButton.setTitle("Apply Filters", for: .normal)

        let stack = UIStackView(arrangedSubviews: [applyButton, closeButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
