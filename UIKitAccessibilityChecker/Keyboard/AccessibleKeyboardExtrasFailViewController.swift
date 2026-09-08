import UIKit

/// KEYBOARD — Fail tier, extras.
///
/// Partial neglected the screen-level keyboard concerns. This file works
/// against them: focus is forcibly reset while the user is moving, the
/// focus ring is suppressed on purpose, Escape is bound to a destructive
/// action, the panel is an inescapable trap, and the software keyboard is
/// allowed to cover the field being typed into with no scrolling at all.
/// Deliberately broken; reference only.
///
/// Element-by-element:
///   1. Focus order         — focus forced back to the first field on
///                            every update, so it cannot advance
///   2. Focus grouping      — the group is set to a priority that pulls
///                            focus into it from anywhere on screen
///   3. Modal focus trap    — panel with no close control, no Escape,
///                            and isModalInPresentation; a dead end
///   4. Focus indicator     — focusEffect set to nil everywhere, so focus
///                            is completely invisible
///   5. Return-key chaining — Return clears the form
///   6. Escape to dismiss   — Escape bound to a destructive delete
///   7. Scroll into view    — focus change scrolls AWAY from the focused
///                            control
///   8. Keyboard avoidance  — layout pinned so the keyboard permanently
///                            covers the last two fields
///   9. Alert dialog        — destructive action set as preferredAction,
///                            so Return deletes; no cancel-style action,
///                            so Escape cannot dismiss
///   10. Popover            — passthroughViews leaves focus behind it and
///                            the content itself is unreachable
final class AccessibleKeyboardExtrasFailViewController: UIViewController {

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
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        firstNameField.placeholder = "First name"
        lastNameField.placeholder = "Last name"
        emailField.placeholder = "Email"
        bottomField.placeholder = "Notes"
        [firstNameField, lastNameField, emailField, bottomField].forEach {
            $0.borderStyle = .roundedRect
            $0.delegate = self
            $0.returnKeyType = .next // implies advancement; does the opposite
            // 4. Focus made invisible on every field.
            $0.focusEffect = nil
        }

        submitButton.setTitle("Submit", for: .normal)
        submitButton.focusEffect = nil

        // 2. Focus group with a priority that pulls focus toward it. Focus
        // is dragged into the stepper from elsewhere on the screen, so the
        // user cannot stay where they intended to be.
        priceMinusButton.setTitle("−", for: .normal)
        pricePlusButton.setTitle("+", for: .normal)
        priceLabel.text = "$\(price)"
        priceGroup.axis = .horizontal
        priceGroup.spacing = 12
        [priceMinusButton, priceLabel, pricePlusButton].forEach { priceGroup.addArrangedSubview($0) }
        priceGroup.focusGroupPriority = .prioritized
        priceGroup.focusEffect = nil

        // 3. Panel with no way out — see FailPanelViewController.
        openPanelButton.setTitle("Open Filter Panel", for: .normal)
        openPanelButton.addAction(UIAction { [weak self] _ in
            self?.presentPanel()
        }, for: .touchUpInside)

        // 9. Alert — the destructive action is set as preferredAction, so
        // Return deletes the account, and there is no .cancel-style action
        // at all, so Escape has nothing to map to. Both reflexive keys are
        // either destructive or dead.
        deleteAccountButton.setTitle("Delete Account", for: .normal)
        deleteAccountButton.focusEffect = nil
        deleteAccountButton.addAction(UIAction { [weak self] _ in
            self?.presentDeleteConfirmation()
        }, for: .touchUpInside)

        // 10. Popover — passthroughViews keeps the screen behind it live,
        // so focus stays outside the popover while it is open, and the
        // content inside is a non-focusable label with interaction off.
        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.focusEffect = nil
        infoButton.addAction(UIAction { [weak self] _ in
            self?.presentInfoPopover()
        }, for: .touchUpInside)

        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 400).isActive = true

        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        [
            vstack([firstNameField, lastNameField, emailField, submitButton]),
            priceGroup,
            openPanelButton,
            deleteAccountButton,
            infoButton,
            spacer,
            bottomField
        ].forEach { contentStack.addArrangedSubview($0) }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .none
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // 8. Fixed height that ignores the keyboard entirely, and
            // scrolling disabled below, so the covered fields cannot be
            // brought into view by any means.
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    // MARK: - Focus, actively fought

    /// 1 and 7 together. Every focus update yanks focus back to the first
    /// field and scrolls the opposite way from wherever focus was heading,
    /// so the user can neither advance nor see where they are.
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if let next = context.nextFocusedView, next != firstNameField {
            let away = next.convert(next.bounds, to: scrollView).offsetBy(dx: 0, dy: -400)
            scrollView.scrollRectToVisible(away, animated: true)
            firstNameField.becomeFirstResponder()
            setNeedsFocusUpdate()
            updateFocusIfNeeded()
        }
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        [firstNameField]
    }

    // MARK: - Keys, bound to the wrong things

    override var canBecomeFirstResponder: Bool { true }

    override var keyCommands: [UIKeyCommand]? {
        [
            // 6. Escape — the universal "get me out of here" — wired to a
            // destructive action with no confirmation and no undo.
            UIKeyCommand(title: "Delete draft",
                         action: #selector(deleteEverything),
                         input: UIKeyCommand.inputEscape),
            // Tab consumed at screen level, so focus cannot traverse.
            UIKeyCommand(action: #selector(noop), input: "\t", modifierFlags: [])
        ]
    }

    @objc private func noop() { }

    @objc private func deleteEverything() {
        [firstNameField, lastNameField, emailField, bottomField].forEach { $0.text = "" }
    }

    private func presentDeleteConfirmation() {
        let alert = UIAlertController(
            title: "Delete your account?",
            message: "This cannot be undone.",
            preferredStyle: .alert
        )
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteEverything()
        }
        // "Not now" is styled .default, not .cancel, so Escape has no
        // action to map to and the dialog cannot be dismissed by keyboard.
        alert.addAction(delete)
        alert.addAction(UIAlertAction(title: "Not now", style: .default))
        // Return fires the destructive action.
        alert.preferredAction = delete
        present(alert, animated: true)
    }

    private func presentInfoPopover() {
        let contentVC = UIViewController()
        contentVC.view.backgroundColor = .secondarySystemBackground
        contentVC.view.isUserInteractionEnabled = false

        let label = UILabel().srcLine()
        label.text = "This feature syncs your data across devices."
        label.numberOfLines = 0
        label.isAccessibilityElement = false
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
            // Keeps the underlying screen interactive, so focus never
            // enters the popover and Tab keeps walking the form behind it
            // while a popover sits on top.
            popover.passthroughViews = [view]
        }
        present(contentVC, animated: true)
    }

    private func presentPanel() {
        let panel = FailPanelViewController()
        panel.modalPresentationStyle = .overFullScreen
        present(panel, animated: true)
    }

    private func vstack(_ views: [UIView]) -> UIView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }
}

extension AccessibleKeyboardExtrasFailViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 5. returnKeyType is .next, so the key is labelled "next" — and
        // it clears the entire form instead of advancing.
        deleteEverything()
        return false
    }
}

/// A full-screen panel with no close button, no Escape command, no swipe
/// dismissal, and focus pinned inside it. Once open, there is no route back
/// to the app by keyboard or by pointer.
final class FailPanelViewController: UIViewController {

    private let applyButton = UIButton(type: .system).srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        isModalInPresentation = true
        view.accessibilityViewIsModal = true

        applyButton.setTitle("Apply Filters", for: .normal)
        applyButton.focusEffect = nil
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(applyButton)
        NSLayoutConstraint.activate([
            applyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            applyButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        [applyButton]
    }

    // No keyCommands, no close control, no dismissal path of any kind.
}
