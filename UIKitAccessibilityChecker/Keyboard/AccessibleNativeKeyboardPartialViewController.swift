import UIKit

/// KEYBOARD — Partial tier, native controls.
///
/// The same nine native controls. Every one is still focusable and every
/// one still works with a pointer. The gaps are the keyboard-only paths
/// that were never tested: a trap with no exit, an action that exists only
/// as a gesture layered on top of a control, and focus that is quietly
/// suppressed on individual elements.
///
/// This tier matters because focusability alone is a weak signal. A
/// checker that asks "can this be focused?" passes most of this file while
/// a keyboard user is still stuck.
///
/// Element-by-element:
///   1. UIButton            — action attached as a tap gesture, not an
///                            addAction, so Space/Return does nothing
///   2. UITextField         — focusable, but Return neither submits nor
///                            advances; the form cannot be completed
///   3. UITextView          — Tab trap with no escape route
///   4. UISwitch            — focusable, but the valueChanged handler is
///                            wired to a tap gesture instead
///   5. UISlider            — fine natively, but wrapped in a container
///                            with isUserInteractionEnabled = false
///   6. UIStepper           — works; the count label it drives is not
///                            focusable, so the result is unverifiable
///   7. UISegmentedControl  — works (automatic)
///   8. UITableView rows    — accessory is a hand-drawn image with a tap
///                            gesture; only reachable by pointer
///   9. UIBarButtonItem     — focus explicitly disabled
///
/// Elements 10 to 15 are the presented controls, and they share one bug in
/// six variations: focus goes somewhere and never comes back. Each one
/// opens correctly, is operable while open, and drops the user at the top
/// of the screen on dismissal. On a form with fifteen stops that means
/// tabbing from the beginning after every menu, picker or push.
///
///   10. UIMenu button      — opens on long press only, not on activation
///   11. Secure text field  — Return does nothing; the form cannot be
///                            submitted from the last field
///   12. UIDatePicker       — popover opens, focus is not returned after
///                            a date is chosen
///   13. UIColorWell        — replaced by hand-drawn swatches with tap
///                            gestures; not focusable at all
///   14. Share button       — sheet presented with no sourceView and no
///                            focus restoration
///   15. Navigation push    — focus resets to the top of the list on pop
final class AccessibleNativeKeyboardPartialViewController: UIViewController {

    // MARK: - Controls

    private let saveButton = UIButton(type: .system).srcLine()
    private let usernameField = UITextField().srcLine()
    private let notesTextView = UITextView().srcLine()
    private let notificationsSwitch = UISwitch().srcLine()
    private let sliderContainer = UIView().srcLine()
    private let volumeSlider = UISlider().srcLine()
    private let quantityStepper = UIStepper().srcLine()
    private let quantityLabel = UILabel().srcLine()
    private let colorSegmentedControl = UISegmentedControl(items: ["Red", "Green", "Blue"]).srcLine()
    private let tableView = UITableView().srcLine()
    private let moreActionsButton = UIButton(type: .system).srcLine()
    private let passwordField = UITextField().srcLine()
    private let birthDatePicker = UIDatePicker().srcLine()
    private let colorSwatchRow = UIStackView().srcLine()
    private let shareButton = UIButton(type: .system).srcLine()
    private let openSettingsButton = UIButton(type: .system).srcLine()

    private let rows = ["Inbox", "Drafts", "Archive"]
    private var quantity = 1 {
        didSet { quantityLabel.text = "\(quantity)" }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Native Keyboard (Partial)"
        view.backgroundColor = .systemBackground

        // 9. Bar button item — focus turned off, so the primary action of
        // the screen is unreachable without a pointer.
        let doneItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        doneItem.isEnabled = true
        doneItem.accessibilityRespondsToUserInteraction = false
        navigationItem.rightBarButtonItem = doneItem

        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 1. Button — the action is a UITapGestureRecognizer rather than a
        // control event. Gesture recognizers respond to touches only, so
        // the button focuses and highlights but Space and Return do
        // nothing at all.
        saveButton.setTitle("Save", for: .normal)
        saveButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveTapped)))

        // 2. Text field — no returnKeyType, no delegate, no submit action.
        // A keyboard user types a value and has no way to commit it or
        // move to the next field except Tab, which some layouts consume.
        usernameField.placeholder = "Username"
        usernameField.borderStyle = .roundedRect

        // 3. Text view — the classic trap. Tab inserts a tab character, no
        // Escape handler exists, and nothing on screen says how to leave.
        // Focus enters and does not come back out.
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.separator.cgColor
        notesTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        // 4. Switch — same bug as the button. Space fires the control's
        // valueChanged, but the app listens for a tap gesture, so toggling
        // by keyboard changes the switch without running any app logic.
        notificationsSwitch.isOn = true
        notificationsSwitch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchTapped)))

        // 5. Slider — a perfectly good UISlider inside a container with
        // interaction disabled for layout reasons. It renders, it cannot
        // be focused, and arrow keys never reach it.
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 0.5
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        sliderContainer.addSubview(volumeSlider)
        sliderContainer.isUserInteractionEnabled = false
        NSLayoutConstraint.activate([
            volumeSlider.topAnchor.constraint(equalTo: sliderContainer.topAnchor),
            volumeSlider.bottomAnchor.constraint(equalTo: sliderContainer.bottomAnchor),
            volumeSlider.leadingAnchor.constraint(equalTo: sliderContainer.leadingAnchor),
            volumeSlider.trailingAnchor.constraint(equalTo: sliderContainer.trailingAnchor),
            volumeSlider.widthAnchor.constraint(equalToConstant: 240)
        ])

        // 6. Stepper — the stepper itself is fine. The label showing the
        // result is not an accessibility element, so a keyboard user can
        // change the quantity and has no way to confirm what it now is.
        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = 10
        quantityStepper.value = 1
        quantityLabel.text = "\(quantity)"
        quantityLabel.isAccessibilityElement = false
        quantityStepper.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.quantity = Int(self.quantityStepper.value)
        }, for: .valueChanged)

        // 7. Segmented control — untouched, works correctly. Included so
        // the ruleset can confirm it does not flag correct native usage.
        colorSegmentedControl.selectedSegmentIndex = 1

        // 8. Table — rows focus and select, but the per-row action lives
        // on a hand-drawn chevron with a tap gesture on it (see
        // cellForRowAt), which no key press can reach.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.heightAnchor.constraint(equalToConstant: 150).isActive = true

        // 10. Menu — showsMenuAsPrimaryAction is left false, so the menu
        // is attached as a secondary action and opens on a long press.
        // Return and Space on the focused button do nothing, and the three
        // actions inside are unreachable by keyboard.
        moreActionsButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        moreActionsButton.accessibilityLabel = "More actions"
        moreActionsButton.menu = UIMenu(children: [
            UIAction(title: "Share") { _ in },
            UIAction(title: "Duplicate") { _ in },
            UIAction(title: "Delete", attributes: .destructive) { _ in }
        ])

        // 11. Secure field — focusable and typable, but returnKeyType is
        // default and there is no delegate, so pressing Return on the last
        // field of the form does nothing. The user has to find the Submit
        // button by tabbing past everything else.
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true

        // 12. Date picker — the compact picker opens its calendar popover
        // and arrow keys work inside it. On dismissal focus is not sent
        // back to the picker, so the user resumes from the top.
        birthDatePicker.datePickerMode = .date
        birthDatePicker.preferredDatePickerStyle = .compact
        birthDatePicker.accessibilityLabel = "Date of birth"

        // 13. Color picker — UIColorWell replaced by four hand-drawn
        // swatches with tap gestures, a common "we wanted custom colours"
        // substitution. None is focusable, so colour cannot be chosen by
        // keyboard at all.
        colorSwatchRow.axis = .horizontal
        colorSwatchRow.spacing = 8
        for color in [UIColor.systemRed, .systemGreen, .systemBlue, .systemOrange] {
            // #line expands at this call site, so all four swatches share this one line —
            // the same inherent limitation loop-built rows have on the State screens.
            let swatch = UIView().srcLine()
            swatch.backgroundColor = color
            swatch.layer.cornerRadius = 14
            swatch.isUserInteractionEnabled = true
            swatch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swatchTapped)))
            swatch.widthAnchor.constraint(equalToConstant: 28).isActive = true
            swatch.heightAnchor.constraint(equalToConstant: 28).isActive = true
            colorSwatchRow.addArrangedSubview(swatch)
        }

        // 14. Share — the sheet is presented with no popover anchor, which
        // means it cannot present on iPad at all, and no completion
        // handler, so focus is lost wherever the sheet leaves it.
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.accessibilityLabel = "Share this page"
        shareButton.addAction(UIAction { [weak self] _ in
            guard let url = URL(string: "https://developer.apple.com") else { return }
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self?.present(activityVC, animated: true)
        }, for: .touchUpInside)

        // 15. Navigation push — the push works and the pushed screen is
        // usable. Coming back, focus resets to the first control on this
        // screen instead of the button that pushed, so drilling into
        // several rows in turn means re-tabbing the whole list each time.
        openSettingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        openSettingsButton.accessibilityLabel = "Open settings"
        openSettingsButton.addAction(UIAction { [weak self] _ in
            let settingsVC = UIViewController()
            settingsVC.title = "Settings"
            settingsVC.view.backgroundColor = .systemBackground
            self?.navigationController?.pushViewController(settingsVC, animated: true)
        }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            row(title: "Button", control: saveButton),
            row(title: "Text Field", control: usernameField),
            row(title: "Text View", control: notesTextView),
            row(title: "Switch", control: notificationsSwitch),
            row(title: "Slider", control: sliderContainer),
            row(title: "Stepper", control: hstack([quantityStepper, quantityLabel])),
            row(title: "Segmented Control", control: colorSegmentedControl),
            row(title: "Table Rows", control: tableView),
            row(title: "Menu", control: moreActionsButton),
            row(title: "Secure Field", control: passwordField),
            row(title: "Date Picker", control: birthDatePicker),
            row(title: "Color Picker", control: colorSwatchRow),
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

    // No keyCommands override anywhere — no Escape, no shortcuts.

    @objc private func saveTapped() { /* save — pointer only */ }
    @objc private func switchTapped() { /* apply setting — pointer only */ }
    @objc private func doneTapped() { /* commit */ }
    @objc private func chevronTapped() { /* open detail — pointer only */ }
    @objc private func swatchTapped() { /* choose colour — pointer only */ }

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

extension AccessibleNativeKeyboardPartialViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = rows[indexPath.row]
        cell.contentConfiguration = config

        // A hand-drawn chevron with a tap gesture instead of an accessory
        // type. Visually identical, reachable only by pointer.
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right")).srcLine()
        chevron.isUserInteractionEnabled = true
        chevron.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chevronTapped)))
        cell.accessoryView = chevron
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Selecting the row does NOT perform the chevron's action, so the
        // keyboard path and the pointer path lead to different places.
    }
}
