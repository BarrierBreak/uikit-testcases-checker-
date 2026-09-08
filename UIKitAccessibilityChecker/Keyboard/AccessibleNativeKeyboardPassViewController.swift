import UIKit

/// KEYBOARD — Pass tier, native controls.
///
/// Everything here is a real UIKit control, so it participates in the focus
/// system automatically: Tab moves between them, Space/Return activates,
/// arrow keys adjust sliders and steppers, and Full Keyboard Access draws a
/// focus ring without any code.
///
/// Two things still need doing by hand, and they are the reason this file
/// is not simply "use native controls and stop thinking about it":
///
///   • UITextView swallows Tab as a literal tab character, so a user who
///     lands in it cannot Tab back out. An escape route must be provided.
///   • A cell whose content is custom-drawn is focusable as a row but has
///     no operable child, so its action needs to be reachable.
///
/// Elements 10 to 15 are the *presented* controls: each one opens a menu,
/// popover, sheet or new screen. For those the keyboard question is not
/// "can this be activated" but "does focus enter the thing it opened, and
/// does it come back afterwards". UIKit handles the first half; the return
/// journey is on the app.
///
/// Elements covered (15):
///   1.  UIButton            — focus + activate      (automatic)
///   2.  UITextField         — focus + type          (automatic)
///   3.  UITextView          — focus + type          (MANUAL — Tab trap)
///   4.  UISwitch            — Space toggles         (automatic)
///   5.  UISlider            — arrow keys adjust     (automatic)
///   6.  UIStepper           — arrow keys adjust     (automatic)
///   7.  UISegmentedControl  — arrow keys move       (automatic)
///   8.  UITableView rows    — arrows + Return       (MANUAL — custom cell)
///   9.  UIBarButtonItem     — focus + activate      (automatic)
///   10. UIMenu button       — Return opens, arrows move, Escape closes
///                                                   (automatic if primary action)
///   11. Secure text field   — focus + type          (MANUAL — Return path)
///   12. UIDatePicker        — opens a calendar popover
///                                                   (MANUAL — focus return)
///   13. UIColorWell         — opens the system picker
///                                                   (MANUAL — focus return)
///   14. Share button        — opens UIActivityViewController
///                                                   (MANUAL — focus return)
///   15. Navigation push     — pushes a screen       (MANUAL — focus on pop)
final class AccessibleNativeKeyboardPassViewController: UIViewController {

    // MARK: - Controls

    private let saveButton = UIButton(type: .system).srcLine()
    private let usernameField = UITextField().srcLine()
    private let notesTextView = UITextView().srcLine()
    private let notesHintLabel = UILabel().srcLine()
    private let notificationsSwitch = UISwitch().srcLine()
    private let volumeSlider = UISlider().srcLine()
    private let quantityStepper = UIStepper().srcLine()
    private let quantityLabel = UILabel().srcLine()
    private let colorSegmentedControl = UISegmentedControl(items: ["Red", "Green", "Blue"]).srcLine()
    private let tableView = UITableView().srcLine()
    private let moreActionsButton = UIButton(type: .system).srcLine()
    private let passwordField = UITextField().srcLine()
    private let birthDatePicker = UIDatePicker().srcLine()
    private let favoriteColorWell = UIColorWell().srcLine()
    private let shareButton = UIButton(type: .system).srcLine()
    private let openSettingsButton = UIButton(type: .system).srcLine()

    /// Remembers which control opened a presentation so focus can be sent
    /// back to it, rather than to the top of the screen, on dismissal.
    private weak var focusReturnTarget: UIView?

    private let rows = ["Inbox", "Drafts", "Archive"]
    private var quantity = 1 {
        didSet { quantityLabel.text = "\(quantity)" }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Native Keyboard (Pass)"
        view.backgroundColor = .systemBackground

        // 9. Bar button item — focusable and activatable with no extra
        // work. Giving it a key equivalent as well is a bonus, not a fix.
        let doneItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneItem

        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 1. Button — Tab focuses it, Space or Return activates it. The
        // focus ring is drawn by the system.
        saveButton.setTitle("Save", for: .normal)
        saveButton.addAction(UIAction { [weak self] _ in
            self?.save()
        }, for: .touchUpInside)

        // 2. Text field — focusable, typable, and Tab moves on to the next
        // field because UITextField does not consume the Tab key.
        usernameField.placeholder = "Username"
        usernameField.borderStyle = .roundedRect

        // 3. Text view — the Tab trap. UITextView inserts a literal tab
        // rather than moving focus, so a keyboard user can enter this view
        // and never leave it. Two fixes together:
        //   • Escape resigns first responder, returning focus to the view.
        //   • The behaviour is stated on screen, since an undiscoverable
        //     escape hatch is nearly as bad as none.
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.separator.cgColor
        notesTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        notesHintLabel.text = "Press Escape to leave this field."
        notesHintLabel.font = .preferredFont(forTextStyle: .footnote)
        notesHintLabel.textColor = .secondaryLabel

        // 4. Switch — Space toggles it.
        notificationsSwitch.isOn = true

        // 5. Slider — left/right arrows step the value once focused.
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 0.5

        // 6. Stepper — up/down and left/right arrows increment/decrement.
        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = 10
        quantityStepper.value = 1
        quantityLabel.text = "\(quantity)"
        quantityStepper.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.quantity = Int(self.quantityStepper.value)
        }, for: .valueChanged)

        // 7. Segmented control — arrow keys move between segments.
        colorSegmentedControl.selectedSegmentIndex = 1

        // 8. Table view — rows are focusable and Return selects. The row
        // here draws its own accessory rather than using a real button, so
        // the accessory's action is exposed as a row-level selection
        // instead of an unreachable tap target.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.heightAnchor.constraint(equalToConstant: 150).isActive = true

        // 10. Menu. showsMenuAsPrimaryAction is what makes the menu open
        // on activation — Return, Space, or a click — rather than on a
        // long press. UIKit then handles focus inside the menu itself:
        // arrows move between actions and Escape closes without choosing.
        // Every UIAction carries a real title, because an icon-only action
        // is a focus stop with nothing to announce.
        moreActionsButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        moreActionsButton.accessibilityLabel = "More actions"
        moreActionsButton.showsMenuAsPrimaryAction = true
        moreActionsButton.menu = UIMenu(children: [
            UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in },
            UIAction(title: "Duplicate", image: UIImage(systemName: "plus.square.on.square")) { _ in },
            UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in }
        ])

        // 11. Secure field. Focus and typing are automatic, but a password
        // field is almost always the last field before submission, so
        // Return has to do something. Here it commits the form.
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .password
        passwordField.returnKeyType = .go
        passwordField.delegate = self

        // 12. Date picker. The compact style is a focusable button that
        // opens a calendar popover; arrow keys traverse the date grid
        // inside it. What UIKit does not do is put focus back afterwards,
        // so the picker is registered as the return target.
        birthDatePicker.datePickerMode = .date
        birthDatePicker.preferredDatePickerStyle = .compact
        birthDatePicker.accessibilityLabel = "Date of birth"
        birthDatePicker.addAction(UIAction { [weak self] _ in
            self?.focusReturnTarget = self?.birthDatePicker
        }, for: .editingDidBegin)

        // 13. Color well. Activating it presents the system colour picker,
        // a modal this code does not own. Focus travels into it correctly;
        // returning focus to the well on dismissal is the app's job.
        favoriteColorWell.accessibilityLabel = "Favorite color"
        favoriteColorWell.supportsAlpha = false
        favoriteColorWell.addAction(UIAction { [weak self] _ in
            self?.focusReturnTarget = self?.favoriteColorWell
        }, for: .valueChanged)

        // 14. Share. UIActivityViewController is another system modal.
        // sourceView is set because the sheet is a popover on iPad, and a
        // popover with no anchor cannot be presented at all. The
        // completion handler is where focus comes home.
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.accessibilityLabel = "Share this page"
        shareButton.addAction(UIAction { [weak self] _ in
            self?.presentShareSheet()
        }, for: .touchUpInside)

        // 15. Navigation push. On push, focus should start on the new
        // screen's content. On pop, it should return to the row that
        // pushed it — otherwise a keyboard user who drills into the fifth
        // item and comes back has to tab from the top again.
        openSettingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        openSettingsButton.accessibilityLabel = "Open settings"
        openSettingsButton.addAction(UIAction { [weak self] _ in
            self?.pushSettings()
        }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            row(title: "Button", control: saveButton),
            row(title: "Text Field", control: usernameField),
            row(title: "Text View", control: vstack([notesTextView, notesHintLabel])),
            row(title: "Switch", control: notificationsSwitch),
            row(title: "Slider", control: volumeSlider),
            row(title: "Stepper", control: hstack([quantityStepper, quantityLabel])),
            row(title: "Segmented Control", control: colorSegmentedControl),
            row(title: "Table Rows", control: tableView),
            row(title: "Menu", control: moreActionsButton),
            row(title: "Secure Field", control: passwordField),
            row(title: "Date Picker", control: birthDatePicker),
            row(title: "Color Picker", control: favoriteColorWell),
            row(title: "Share", control: shareButton),
            row(title: "Navigation Push", control: openSettingsButton)
        ])
        stack.axis = .vertical
        stack.spacing = 20
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

    // MARK: - Key commands

    /// Escape releases the text view, which is the fix for the Tab trap.
    /// discoverabilityTitle makes the shortcut appear in the hold-Command
    /// overlay so it can be found rather than guessed.
    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(
                title: "Leave text field",
                action: #selector(resignTextView),
                input: UIKeyCommand.inputEscape
            )
        ]
    }

    override var canBecomeFirstResponder: Bool { true }

    @objc private func resignTextView() {
        notesTextView.resignFirstResponder()
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }

    @objc private func doneTapped() { /* commit */ }
    private func save() { /* save */ }

    // MARK: - Presentations and focus return

    private func presentShareSheet() {
        guard let url = URL(string: "https://developer.apple.com") else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        // Required for the iPad popover presentation; without an anchor
        // the sheet cannot be presented, keyboard or not.
        activityVC.popoverPresentationController?.sourceView = shareButton
        activityVC.popoverPresentationController?.sourceRect = shareButton.bounds
        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.restoreFocus(to: self?.shareButton)
        }
        focusReturnTarget = shareButton
        present(activityVC, animated: true)
    }

    private func pushSettings() {
        let settingsVC = KbdSettingsViewController()
        settingsVC.onPopped = { [weak self] in
            // Focus comes back to the row that pushed, not the top.
            self?.restoreFocus(to: self?.openSettingsButton)
        }
        focusReturnTarget = openSettingsButton
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    private func restoreFocus(to view: UIView?) {
        focusReturnTarget = view
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }

    /// Focus is directed at whatever last opened a presentation, so
    /// dismissing a menu, popover, sheet or pushed screen returns the user
    /// to where they were.
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let target = focusReturnTarget { return [target] }
        return super.preferredFocusEnvironments
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
        stack.spacing = 4
        return stack
    }

    private func hstack(_ views: [UIView]) -> UIView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }
}

// MARK: - 11. Secure field Return path

extension AccessibleNativeKeyboardPassViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordField {
            passwordField.resignFirstResponder()
            save()
        }
        return false
    }
}

/// The pushed screen. Focus starts on its content rather than staying
/// behind on the previous view, and the caller is told when it pops so it
/// can take focus back.
final class KbdSettingsViewController: UIViewController {

    var onPopped: (() -> Void)?
    private let firstControl = UIButton(type: .system).srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        firstControl.setTitle("Reset all settings", for: .normal)
        firstControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(firstControl)
        NSLayoutConstraint.activate([
            firstControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }

    /// Focus lands on the new screen's first control after the push.
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        [firstControl]
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent { onPopped?() }
    }
}

extension AccessibleNativeKeyboardPassViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = rows[indexPath.row]
        cell.contentConfiguration = config
        // The disclosure is an accessory type, not a hand-drawn image with
        // a gesture on it, so activating the row activates the action.
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Reached identically by tap and by Return on a focused row.
    }
}
