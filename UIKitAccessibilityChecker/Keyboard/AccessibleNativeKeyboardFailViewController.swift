import UIKit

/// KEYBOARD — Fail tier, native controls.
///
/// Partial left keyboard paths incomplete. This file actively removes or
/// hijacks them: focus is disabled on controls that work, standard keys are
/// rebound to unrelated actions, and a modal traps focus with no way out.
/// A keyboard-only user cannot complete this screen at all, and in two
/// cases pressing an ordinary key does something destructive.
/// Deliberately broken; reference only.
///
/// Element-by-element:
///   1. UIButton            — isEnabled = false, but still performs its
///                            action on tap; unreachable by key
///   2. UITextField         — Return bound to Delete instead of submit
///   3. UITextView          — Tab trap AND Escape swallowed by a no-op
///   4. UISwitch            — removed from the focus system entirely
///   5. UISlider            — arrow keys intercepted and discarded
///   6. UIStepper           — focus forced to loop back to itself
///   7. UISegmentedControl  — hidden behind an invisible overlay view
///   8. UITableView rows    — selection disabled, rows unfocusable
///   9. UIBarButtonItem     — replaced by a customView with no interaction
///
/// Elements 10 to 15 turn each presented control into a dead end: something
/// opens that the keyboard cannot close, or cannot enter, or that discards
/// the user's position entirely.
///
///   10. UIMenu button      — menu on a plain UIView with a long press;
///                            actions are icon-only and unlabelled
///   11. Secure text field  — Return clears the password; autofill and
///                            focus both disabled
///   12. UIDatePicker       — replaced by a hand-drawn wheel, pan only
///   13. UIColorWell        — custom swatches with focus refused
///   14. Share button       — sheet presented with no anchor and focus
///                            pinned behind it
///   15. Navigation push    — pushed by a gesture on a label, and the back
///                            button is hidden, so there is no return path
final class AccessibleNativeKeyboardFailViewController: UIViewController {

    // MARK: - Controls

    private let saveButton = UIButton(type: .system).srcLine()
    private let usernameField = UITextField().srcLine()
    private let notesTextView = UITextView().srcLine()
    private let notificationsSwitch = UISwitch().srcLine()
    private let volumeSlider = UISlider().srcLine()
    private let quantityStepper = UIStepper().srcLine()
    private let colorSegmentedControl = UISegmentedControl(items: ["Red", "Green", "Blue"]).srcLine()
    private let blockingOverlay = UIView().srcLine()
    private let tableView = UITableView().srcLine()
    private let menuHostView = UIView().srcLine()
    private let passwordField = UITextField().srcLine()
    private let dateWheel = FailDateWheelView().srcLine()
    private let colorSwatchRow = UIStackView().srcLine()
    private let shareLabel = UILabel().srcLine()
    private let pushLabel = UILabel().srcLine()

    private let rows = ["Inbox", "Drafts", "Archive"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 9. Bar button item — swapped for a customView that is a plain
        // UILabel. It looks like a button, has no control behaviour, and
        // cannot be focused or activated by any input method.
        // The UIBarButtonItem itself is not a UIView, so it cannot carry a source tag — its
        // customView can, and that is the thing the scan actually sees here.
        let fakeDone = UILabel().srcLine()
        fakeDone.text = "Done"
        fakeDone.textColor = .systemBlue
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: fakeDone)

        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 1. Button — disabled for the focus system, live for touches. It
        // is skipped entirely when tabbing, yet still fires on tap, so the
        // two input methods disagree about whether it exists.
        saveButton.setTitle("Save", for: .normal)
        saveButton.isEnabled = false
        saveButton.isUserInteractionEnabled = true
        saveButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveTapped)))

        // 2. Text field — Return is rebound to a destructive action. A
        // keyboard user finishing a field the way every other app works
        // deletes their entry instead of submitting it.
        usernameField.placeholder = "Username"
        usernameField.borderStyle = .roundedRect
        usernameField.delegate = self

        // 3. Text view — trapped, and the escape hatch is deliberately
        // consumed: an Escape key command exists but does nothing, so the
        // shortcut appears in the shortcut overlay and then fails.
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.separator.cgColor
        notesTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        // 4. Switch — pulled out of the focus system while remaining fully
        // functional by touch.
        notificationsSwitch.isOn = true
        notificationsSwitch.accessibilityRespondsToUserInteraction = false
        notificationsSwitch.isUserInteractionEnabled = true

        // 5. Slider — arrow keys are captured at the view controller level
        // and thrown away, so the focused slider cannot be adjusted even
        // though UISlider handles arrows natively.
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 0.5
        volumeSlider.widthAnchor.constraint(equalToConstant: 240).isActive = true

        // 6. Stepper — preferredFocusEnvironments points back at the
        // stepper itself, so once focus lands here every focus update
        // returns it to the same control. Focus cannot advance.
        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = 10
        quantityStepper.value = 1

        // 7. Segmented control — covered by a transparent view that sits
        // above it and takes all interaction. Nothing looks wrong.
        colorSegmentedControl.selectedSegmentIndex = 1
        blockingOverlay.backgroundColor = .clear
        blockingOverlay.isUserInteractionEnabled = true

        // 8. Table — selection switched off and rows made unfocusable, so
        // the list can be read by pointer and reached by nothing else.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.heightAnchor.constraint(equalToConstant: 150).isActive = true

        // 10. Menu — hosted on a bare UIView opened by long press, with
        // icon-only actions. Nothing is focusable, and even if the menu
        // could be opened, its three items have no titles to announce.
        menuHostView.backgroundColor = .secondarySystemBackground
        menuHostView.layer.cornerRadius = 8
        menuHostView.isUserInteractionEnabled = true
        menuHostView.isAccessibilityElement = false
        menuHostView.addInteraction(UIContextMenuInteraction(delegate: self))
        menuHostView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        menuHostView.heightAnchor.constraint(equalToConstant: 44).isActive = true

        // 11. Secure field — focus refused, autofill disabled, and Return
        // wipes the entry. Every route into and out of this field is
        // either blocked or destructive.
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .oneTimeCode // defeats password autofill
        passwordField.accessibilityRespondsToUserInteraction = false
        passwordField.delegate = self

        // 12. Date picker — a hand-drawn wheel driven by panning. There is
        // no text entry alternative and no key handling, so a date simply
        // cannot be set without a pointer.

        // 13. Color picker — custom swatches with focus explicitly
        // refused, so Full Keyboard Access cannot reach them either.
        colorSwatchRow.axis = .horizontal
        colorSwatchRow.spacing = 8
        for color in [UIColor.systemRed, .systemGreen, .systemBlue, .systemOrange] {
            // #line expands at this call site, so all four swatches share this one line —
            // the same inherent limitation loop-built rows have on the State screens.
            let swatch = UIView().srcLine()
            swatch.backgroundColor = color
            swatch.layer.cornerRadius = 14
            swatch.isUserInteractionEnabled = true
            swatch.isAccessibilityElement = false
            swatch.accessibilityRespondsToUserInteraction = false
            swatch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swatchTapped)))
            swatch.widthAnchor.constraint(equalToConstant: 28).isActive = true
            swatch.heightAnchor.constraint(equalToConstant: 28).isActive = true
            colorSwatchRow.addArrangedSubview(swatch)
        }

        // 14. Share — triggered by a tap gesture on a label, presented
        // with no popover anchor, and focus stays pinned to the stepper
        // behind the sheet via preferredFocusEnvironments below. The sheet
        // is on screen and the focus ring is behind it.
        shareLabel.text = "Share"
        shareLabel.textColor = .systemBlue
        shareLabel.isUserInteractionEnabled = true
        shareLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareTapped)))

        // 15. Navigation push — a label with a tap gesture pushes a screen
        // that hides its own back button. There is no Escape, no back
        // swipe for keyboard users, and no focusable control that returns.
        pushLabel.text = "Open Settings"
        pushLabel.textColor = .systemBlue
        pushLabel.isUserInteractionEnabled = true
        pushLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushTapped)))

        let segmentContainer = UIView()
        colorSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        blockingOverlay.translatesAutoresizingMaskIntoConstraints = false
        segmentContainer.addSubview(colorSegmentedControl)
        segmentContainer.addSubview(blockingOverlay)
        NSLayoutConstraint.activate([
            colorSegmentedControl.topAnchor.constraint(equalTo: segmentContainer.topAnchor),
            colorSegmentedControl.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor),
            colorSegmentedControl.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor),
            colorSegmentedControl.trailingAnchor.constraint(equalTo: segmentContainer.trailingAnchor),
            blockingOverlay.topAnchor.constraint(equalTo: segmentContainer.topAnchor),
            blockingOverlay.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor),
            blockingOverlay.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor),
            blockingOverlay.trailingAnchor.constraint(equalTo: segmentContainer.trailingAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [
            saveButton,
            usernameField,
            notesTextView,
            notificationsSwitch,
            volumeSlider,
            quantityStepper,
            segmentContainer,
            tableView,
            menuHostView,
            passwordField,
            dateWheel,
            colorSwatchRow,
            shareLabel,
            pushLabel
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView().srcLine()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    // MARK: - Focus and keys, both hijacked

    /// Focus is pinned to the stepper, so every focus update drags it back
    /// and no other control can ever be reached by Tab.
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        [quantityStepper]
    }

    override var canBecomeFirstResponder: Bool { true }

    override var keyCommands: [UIKeyCommand]? {
        [
            // Advertised in the shortcut overlay, wired to nothing.
            UIKeyCommand(title: "Leave text field", action: #selector(noop), input: UIKeyCommand.inputEscape),
            // Arrow keys swallowed before the focused slider sees them.
            UIKeyCommand(action: #selector(noop), input: UIKeyCommand.inputLeftArrow),
            UIKeyCommand(action: #selector(noop), input: UIKeyCommand.inputRightArrow)
        ]
    }

    @objc private func noop() { }
    @objc private func saveTapped() { /* pointer-only save */ }
    @objc private func swatchTapped() { /* pointer-only colour choice */ }

    @objc private func shareTapped() {
        guard let url = URL(string: "https://developer.apple.com") else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        // No sourceView: unpresentable on iPad, and focus is never moved
        // into the sheet on iPhone either.
        present(activityVC, animated: true)
    }

    @objc private func pushTapped() {
        let settingsVC = UIViewController()
        settingsVC.view.backgroundColor = .systemBackground
        // No back button and no Escape handler — a keyboard user who
        // reaches this screen cannot leave it.
        settingsVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}

// MARK: - 10. Context menu with unlabelled actions

extension AccessibleNativeKeyboardFailViewController: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(children: [
                UIAction(title: "", image: UIImage(systemName: "square.and.arrow.up")) { _ in },
                UIAction(title: "", image: UIImage(systemName: "plus.square.on.square")) { _ in },
                UIAction(title: "", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in }
            ])
        }
    }
}

// MARK: - 2 and 11. Return rebound to a destructive action
//
// Both text fields on this screen — the username field and the secure password field —
// use this one delegate, so Return clears whichever field the user was finishing.

extension AccessibleNativeKeyboardFailViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Return is rebound to a destructive action instead of submitting or advancing.
        textField.text = ""
        return false
    }
}

/// 12. A hand-drawn date wheel. Panning changes the date; no key, no text
/// entry, no focus, no accessibility element of any kind.
final class FailDateWheelView: UIView {

    private(set) var dayOffset = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        widthAnchor.constraint(equalToConstant: 200).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        dayOffset = Int(gesture.translation(in: self).y / 10)
        setNeedsDisplay()
    }
}

extension AccessibleNativeKeyboardFailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = rows[indexPath.row]
        cell.contentConfiguration = config
        cell.isUserInteractionEnabled = false
        return cell
    }

    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        false
    }
}
