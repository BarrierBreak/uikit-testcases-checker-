//
//  AccessibleFocusOrderOverlapFailViewController.swift
//  Accessibility test cases: Focus order (UIKit)
//
//  WCAG 2.4.3 Focus Order (Level A)
//  Primary test method: Full Keyboard Access (Tab / Shift-Tab)
//
//  Full Keyboard Access moves by on-screen position, so these cases break the
//  order through what is on screen, not through code order:
//
//    FO-01  Custom tabs: the inactive "Register" panel is only covered by the
//           "Sign in" panel, never hidden. Tab keeps landing on invisible
//           Register controls between the visible Sign in controls.
//    FO-02  Grouped containers: Full name and PIN code share one group that
//           spans the form, Address and City are in a second group in the
//           middle. Tab: Full name -> PIN code -> Address -> City.
//    FO-03  Bottom-sheet dialog is not modal: focus stays behind it and Tab
//           goes through the whole page before reaching the dialog.
//
//  The scan cannot tap the segmented control, so each case is its own screen class:
//    AccessibleFocusOrderOverlapFailViewController         FO-01 (initial case)
//    AccessibleFocusOrderOverlapGroupsFailViewController   FO-02
//    AccessibleFocusOrderOverlapSheetFailViewController    FO-03
//
//  Elements covered (what the focus-order rule reports):
//    FO-02  the two sibling groups interleave (Full name, PIN code, Address, City) -> BB40053 Validate
//    FO-01 and FO-03 break the order through coverage and a non-modal sheet, which the
//    focus-order rule does not read, so they report nothing in the focusOrder family.
//

import UIKit

class AccessibleFocusOrderOverlapFailViewController: UIViewController, UITextFieldDelegate {

    /// The case shown first (0 = FO-01, 1 = FO-02, 2 = FO-03).
    class var initialCase: Int { 0 }

    // MARK: - Case switcher

    private let segmentedControl = UISegmentedControl(items: ["FO-01", "FO-02", "FO-03"])
    private let tabsCaseView = UIView()
    private let groupsCaseView = UIView()
    private let dialogCaseView = UIView()

    // MARK: - FO-01 views

    private let signInTabButton = UIButton(type: .system)
    private let registerTabButton = UIButton(type: .system)
    private let signInPanel = UIView()
    private let registerPanel = UIView()

    private let signInEmailField = UITextField()
    private let signInPasswordField = UITextField()
    private let signInButton = UIButton(type: .system)
    private let signInStatusLabel = UILabel()

    private let registerNameField = UITextField()
    private let registerEmailField = UITextField()
    private let registerPasswordField = UITextField()
    private let createAccountButton = UIButton(type: .system)
    private let registerStatusLabel = UILabel()

    // MARK: - FO-02 views

    private let shippingHeading = UILabel()
    private let outerGroup = UIView()   // Full name (top) + PIN code (bottom)
    private let middleGroup = UIView()  // Address + City (middle)
    private let nameField = UITextField()
    private let addressField = UITextField()
    private let cityField = UITextField()
    private let pincodeField = UITextField()
    private let saveAddressButton = UIButton(type: .system)
    private let addressStatusLabel = UILabel()

    // MARK: - FO-03 views

    private let accountHeading = UILabel()
    private let accountStatusLabel = UILabel()
    private let deleteAccountButton = UIButton(type: .system)
    private let contactSupportButton = UIButton(type: .system)
    private let privacyButton = UIButton(type: .system)
    private let signOutButton = UIButton(type: .system)
    private let dimmingView = UIView()
    private let sheetView = UIView()
    private let sheetTitleLabel = UILabel()
    private let sheetMessageLabel = UILabel()
    private let sheetDeleteButton = UIButton(type: .system)
    private let sheetCancelButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Focus Order"
        view.backgroundColor = .systemBackground

        setUpSegmentedControl()
        setUpTabsCase()
        setUpGroupsCase()
        setUpDialogCase()
        setUpSheet()
        showCase(Self.initialCase)
        segmentedControl.selectedSegmentIndex = Self.initialCase
        if Self.initialCase == 2 { openSheet() }
    }

    // MARK: - Case switcher

    private func setUpSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.accessibilityLabel = "Test case"
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])

        for caseView in [tabsCaseView, groupsCaseView, dialogCaseView] {
            caseView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(caseView)
            NSLayoutConstraint.activate([
                caseView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
                caseView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                caseView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                caseView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }

    @objc private func segmentChanged() {
        showCase(segmentedControl.selectedSegmentIndex)
    }

    private func showCase(_ index: Int) {
        view.endEditing(true)
        hideSheet()
        tabsCaseView.isHidden = index != 0
        groupsCaseView.isHidden = index != 1
        dialogCaseView.isHidden = index != 2
    }

    // MARK: - FO-01  Inactive tab panel covered, not hidden

    private func setUpTabsCase() {
        // Tab buttons
        signInTabButton.addTarget(self, action: #selector(signInTabTapped), for: .touchUpInside)
        registerTabButton.addTarget(self, action: #selector(registerTabTapped), for: .touchUpInside)
        let tabRow = UIStackView(arrangedSubviews: [signInTabButton, registerTabButton])
        tabRow.axis = .horizontal
        tabRow.spacing = 12
        tabRow.distribution = .fillEqually
        tabRow.translatesAutoresizingMaskIntoConstraints = false
        tabsCaseView.addSubview(tabRow)

        // Register panel (inactive at start)
        configureField(registerNameField, placeholder: "Full name")
        configureField(registerEmailField, placeholder: "Email")
        configureEmail(registerEmailField)
        configureField(registerPasswordField, placeholder: "Create password")
        registerPasswordField.isSecureTextEntry = true
        registerPasswordField.returnKeyType = .done
        configureButton(createAccountButton, title: "Create account", prominent: true)
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        configureStatus(registerStatusLabel)

        let registerStack = makeStack([registerNameField, registerEmailField,
                                       registerPasswordField, createAccountButton,
                                       registerStatusLabel])
        registerStack.spacing = 28 // rows sit between the Sign in rows
        registerPanel.backgroundColor = .systemBackground
        registerPanel.translatesAutoresizingMaskIntoConstraints = false
        registerPanel.addSubview(registerStack)

        // Sign in panel (active at start)
        configureField(signInEmailField, placeholder: "Email")
        configureEmail(signInEmailField)
        configureField(signInPasswordField, placeholder: "Password")
        signInPasswordField.isSecureTextEntry = true
        signInPasswordField.returnKeyType = .done
        configureButton(signInButton, title: "Sign In", prominent: true)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        configureStatus(signInStatusLabel)

        let signInStack = makeStack([signInEmailField, signInPasswordField,
                                     signInButton, signInStatusLabel])
        signInPanel.backgroundColor = .systemBackground
        signInPanel.translatesAutoresizingMaskIntoConstraints = false
        signInPanel.addSubview(signInStack)

        // Both panels fill the same area. The inactive one is only covered.
        tabsCaseView.addSubview(registerPanel)
        tabsCaseView.addSubview(signInPanel)

        for (panel, stack) in [(registerPanel, registerStack), (signInPanel, signInStack)] {
            NSLayoutConstraint.activate([
                panel.topAnchor.constraint(equalTo: tabRow.bottomAnchor, constant: 16),
                panel.leadingAnchor.constraint(equalTo: tabsCaseView.leadingAnchor),
                panel.trailingAnchor.constraint(equalTo: tabsCaseView.trailingAnchor),
                panel.bottomAnchor.constraint(equalTo: tabsCaseView.bottomAnchor),

                stack.topAnchor.constraint(equalTo: panel.topAnchor),
                stack.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
                stack.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16)
            ])
        }

        NSLayoutConstraint.activate([
            tabRow.topAnchor.constraint(equalTo: tabsCaseView.topAnchor),
            tabRow.leadingAnchor.constraint(equalTo: tabsCaseView.leadingAnchor, constant: 16),
            tabRow.trailingAnchor.constraint(equalTo: tabsCaseView.trailingAnchor, constant: -16)
        ])

        selectTab(signIn: true)
    }

    private func selectTab(signIn: Bool) {
        // Defect: the inactive panel is only moved behind the active one.
        // It is never hidden (isHidden / accessibilityElementsHidden), so
        // Full Keyboard Access still moves through its controls.
        tabsCaseView.bringSubviewToFront(signIn ? signInPanel : registerPanel)

        styleTab(signInTabButton, title: "Sign in", selected: signIn)
        styleTab(registerTabButton, title: "Register", selected: !signIn)
    }

    private func styleTab(_ button: UIButton, title: String, selected: Bool) {
        var config: UIButton.Configuration = selected ? .borderedProminent() : .bordered()
        config.title = title
        button.configuration = config
        if selected {
            button.accessibilityTraits.insert(.selected)
        } else {
            button.accessibilityTraits.remove(.selected)
        }
    }

    @objc private func signInTabTapped() {
        view.endEditing(true)
        selectTab(signIn: true)
    }

    @objc private func registerTabTapped() {
        view.endEditing(true)
        selectTab(signIn: false)
    }

    @objc private func signInTapped() {
        view.endEditing(true)
        let email = signInEmailField.text ?? ""
        let password = signInPasswordField.text ?? ""
        signInStatusLabel.text = email.isEmpty || password.isEmpty
            ? "Enter email and password."
            : "Signed in as \(email)."
    }

    @objc private func createAccountTapped() {
        view.endEditing(true)
        let name = registerNameField.text ?? ""
        registerStatusLabel.text = name.isEmpty
            ? "Enter your full name."
            : "Account created for \(name)."
    }

    // MARK: - FO-02  Grouped containers out of order

    private func setUpGroupsCase() {
        configureHeading(shippingHeading, text: "Shipping address", style: .title2)
        configureField(nameField, placeholder: "Full name")
        configureField(addressField, placeholder: "Address")
        configureField(cityField, placeholder: "City")
        configureField(pincodeField, placeholder: "PIN code")
        pincodeField.returnKeyType = .done
        configureButton(saveAddressButton, title: "Save address", prominent: true)
        saveAddressButton.addTarget(self, action: #selector(saveAddressTapped), for: .touchUpInside)
        configureStatus(addressStatusLabel)

        // Defect: Full name and PIN code are in one group whose frame spans
        // the whole form. Address and City are in a second group in the
        // middle. Assistive tech finishes a group before moving to the next,
        // so focus goes Full name -> PIN code -> Address -> City.
        outerGroup.shouldGroupAccessibilityChildren = true
        middleGroup.shouldGroupAccessibilityChildren = true

        for item in [shippingHeading, outerGroup, middleGroup,
                     saveAddressButton, addressStatusLabel] as [UIView] {
            item.translatesAutoresizingMaskIntoConstraints = false
            groupsCaseView.addSubview(item)
        }
        for item in [nameField, pincodeField] {
            item.translatesAutoresizingMaskIntoConstraints = false
            outerGroup.addSubview(item)
        }
        for item in [addressField, cityField] {
            item.translatesAutoresizingMaskIntoConstraints = false
            middleGroup.addSubview(item)
        }

        let container = groupsCaseView
        NSLayoutConstraint.activate([
            shippingHeading.topAnchor.constraint(equalTo: container.topAnchor),
            shippingHeading.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            shippingHeading.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            // Outer group spans from Full name down to PIN code
            outerGroup.topAnchor.constraint(equalTo: shippingHeading.bottomAnchor, constant: 16),
            outerGroup.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            outerGroup.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            nameField.topAnchor.constraint(equalTo: outerGroup.topAnchor),
            nameField.leadingAnchor.constraint(equalTo: outerGroup.leadingAnchor),
            nameField.trailingAnchor.constraint(equalTo: outerGroup.trailingAnchor),

            // Middle group sits between Full name and PIN code, on top of the
            // outer group (added after it, so it receives touches).
            middleGroup.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 16),
            middleGroup.leadingAnchor.constraint(equalTo: outerGroup.leadingAnchor),
            middleGroup.trailingAnchor.constraint(equalTo: outerGroup.trailingAnchor),

            addressField.topAnchor.constraint(equalTo: middleGroup.topAnchor),
            addressField.leadingAnchor.constraint(equalTo: middleGroup.leadingAnchor),
            addressField.trailingAnchor.constraint(equalTo: middleGroup.trailingAnchor),

            cityField.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: 16),
            cityField.leadingAnchor.constraint(equalTo: middleGroup.leadingAnchor),
            cityField.trailingAnchor.constraint(equalTo: middleGroup.trailingAnchor),
            cityField.bottomAnchor.constraint(equalTo: middleGroup.bottomAnchor),

            pincodeField.topAnchor.constraint(equalTo: middleGroup.bottomAnchor, constant: 16),
            pincodeField.leadingAnchor.constraint(equalTo: outerGroup.leadingAnchor),
            pincodeField.trailingAnchor.constraint(equalTo: outerGroup.trailingAnchor),
            pincodeField.bottomAnchor.constraint(equalTo: outerGroup.bottomAnchor),

            saveAddressButton.topAnchor.constraint(equalTo: outerGroup.bottomAnchor, constant: 24),
            saveAddressButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            saveAddressButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            addressStatusLabel.topAnchor.constraint(equalTo: saveAddressButton.bottomAnchor, constant: 12),
            addressStatusLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            addressStatusLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
    }

    @objc private func saveAddressTapped() {
        view.endEditing(true)
        addressStatusLabel.text = "Address saved."
    }

    // MARK: - FO-03  Bottom-sheet dialog that is not modal

    private func setUpDialogCase() {
        configureHeading(accountHeading, text: "Account settings", style: .title2)

        accountStatusLabel.text = "Account active"
        accountStatusLabel.font = .preferredFont(forTextStyle: .headline)
        accountStatusLabel.adjustsFontForContentSizeCategory = true
        accountStatusLabel.numberOfLines = 0

        configureButton(deleteAccountButton, title: "Delete account", prominent: false)
        deleteAccountButton.configuration?.baseForegroundColor = .systemRed
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)

        configureButton(contactSupportButton, title: "Contact support", prominent: false)
        contactSupportButton.addTarget(self, action: #selector(contactSupportTapped), for: .touchUpInside)

        configureButton(privacyButton, title: "Privacy settings", prominent: false)
        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)

        configureButton(signOutButton, title: "Sign out", prominent: false)
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)

        let stack = makeStack([accountHeading, accountStatusLabel, deleteAccountButton,
                               contactSupportButton, privacyButton, signOutButton])
        pin(stack, to: dialogCaseView)
    }

    private func setUpSheet() {
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.isHidden = true
        dimmingView.isAccessibilityElement = false
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(sheetCancelTapped))
        )
        view.addSubview(dimmingView)

        sheetView.backgroundColor = .secondarySystemBackground
        sheetView.layer.cornerRadius = 20
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.isHidden = true
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        // Defect: the sheet is not modal and focus is not moved into it.
        sheetView.accessibilityViewIsModal = false
        view.addSubview(sheetView)

        sheetTitleLabel.text = "Delete account?"
        sheetTitleLabel.font = .preferredFont(forTextStyle: .headline)
        sheetTitleLabel.adjustsFontForContentSizeCategory = true
        sheetTitleLabel.accessibilityTraits.insert(.header)
        sheetTitleLabel.numberOfLines = 0

        sheetMessageLabel.text = "This action cannot be undone."
        sheetMessageLabel.font = .preferredFont(forTextStyle: .subheadline)
        sheetMessageLabel.adjustsFontForContentSizeCategory = true
        sheetMessageLabel.numberOfLines = 0

        configureButton(sheetDeleteButton, title: "Delete", prominent: true)
        sheetDeleteButton.configuration?.baseBackgroundColor = .systemRed
        sheetDeleteButton.addTarget(self, action: #selector(sheetDeleteTapped), for: .touchUpInside)

        configureButton(sheetCancelButton, title: "Cancel", prominent: false)
        sheetCancelButton.addTarget(self, action: #selector(sheetCancelTapped), for: .touchUpInside)

        let sheetStack = makeStack([sheetTitleLabel, sheetMessageLabel,
                                    sheetDeleteButton, sheetCancelButton])
        sheetView.addSubview(sheetStack)

        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            sheetStack.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 24),
            sheetStack.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 8),
            sheetStack.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -8),
            sheetStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    @objc private func deleteAccountTapped() {
        // Defect: the sheet appears at the bottom of the screen, but keyboard
        // focus stays on "Delete account" behind the dimmed overlay. Tab goes
        // through Contact support, Privacy settings and Sign out first.
        openSheet()
    }

    private func openSheet() {
        dimmingView.isHidden = false
        sheetView.isHidden = false
    }

    @objc private func contactSupportTapped() {
        accountStatusLabel.text = "Support request sent"
    }

    @objc private func privacyTapped() {
        accountStatusLabel.text = "Privacy settings opened"
    }

    @objc private func signOutTapped() {
        accountStatusLabel.text = "Signed out"
    }

    @objc private func sheetCancelTapped() {
        hideSheet()
    }

    @objc private func sheetDeleteTapped() {
        accountStatusLabel.text = "Account deleted"
        hideSheet()
    }

    private func hideSheet() {
        dimmingView.isHidden = true
        sheetView.isHidden = true
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case signInEmailField:   signInPasswordField.becomeFirstResponder()
        case registerNameField:  registerEmailField.becomeFirstResponder()
        case registerEmailField: registerPasswordField.becomeFirstResponder()
        case nameField:          addressField.becomeFirstResponder()
        case addressField:       cityField.becomeFirstResponder()
        case cityField:          pincodeField.becomeFirstResponder()
        default:                 textField.resignFirstResponder()
        }
        return true
    }

    // MARK: - Helpers

    private func configureHeading(_ label: UILabel, text: String, style: UIFont.TextStyle) {
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.accessibilityTraits.insert(.header)
    }

    private func configureField(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.accessibilityLabel = placeholder
        field.borderStyle = .roundedRect
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.returnKeyType = .next
        field.delegate = self
    }

    private func configureEmail(_ field: UITextField) {
        field.keyboardType = .emailAddress
        field.textContentType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
    }

    private func configureButton(_ button: UIButton, title: String, prominent: Bool) {
        var config: UIButton.Configuration = prominent ? .borderedProminent() : .bordered()
        config.title = title
        button.configuration = config
    }

    private func configureStatus(_ label: UILabel) {
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
    }

    private func makeStack(_ views: [UIView]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func pin(_ stack: UIStackView, to container: UIView) {
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
    }
}

/// FO-02 as its own screen, so the scan sees the grouped containers.
final class AccessibleFocusOrderOverlapGroupsFailViewController: AccessibleFocusOrderOverlapFailViewController {
    override class var initialCase: Int { 1 }
}

/// FO-03 as its own screen, with the non-modal sheet already open.
final class AccessibleFocusOrderOverlapSheetFailViewController: AccessibleFocusOrderOverlapFailViewController {
    override class var initialCase: Int { 2 }
}
