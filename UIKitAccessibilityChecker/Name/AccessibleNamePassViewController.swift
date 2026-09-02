import UIKit

/// UIKit equivalent of AccessibleNamePass. Every interactive control gets
/// an explicit `accessibilityLabel` (and `accessibilityHint`/`accessibilityValue`
/// where useful), because UIKit — unlike SwiftUI's Toggle/Slider/Picker — does
/// NOT automatically pick up a sibling UILabel's text as a control's label.
final class AccessibleNamePassViewController: UIViewController {

    // MARK: - Controls

    private let deleteIconButton = UIButton(type: .system).srcLine()
    private let notificationsSwitch = UISwitch().srcLine()
    private let volumeSlider = UISlider().srcLine()
    private let quantityStepper = UIStepper().srcLine()
    private let quantityValueLabel = UILabel()
    private let colorSegmentedControl = UISegmentedControl(items: ["Red", "Green", "Blue"]).srcLine()
    private let moreActionsButton = UIButton(type: .system).srcLine()
    private let usernameField = UITextField().srcLine()
    private let passwordField = UITextField().srcLine()
    private let notesTextView = UITextView().srcLine()
    private let birthDatePicker = UIDatePicker().srcLine()
    private let favoriteColorWell = NamedColorWell().srcLine()
    private let openWebsiteButton = UIButton(type: .system).srcLine()
    private let shareButton = UIButton(type: .system).srcLine()
    private let openSettingsButton = UIButton(type: .system).srcLine()
    private let favoriteStarButton = UIButton(type: .system).srcLine()
    private let ratingControl = RatingControl(maximumRating: 5).srcLine()
    private let agreeSwitch = UISwitch().srcLine()
    private let deleteAccountButton = UIButton(type: .system).srcLine()

    private var quantity = 1 {
        didSet { quantityValueLabel.text = "\(quantity)" }
    }
    private var isFavorite = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accessible Controls (Pass)"
        view.backgroundColor = .systemBackground
        buildLayout()
        configureAccessibility()
    }

    // MARK: - Layout

    private func buildLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
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

        deleteIconButton.setImage(UIImage(systemName: "trash"), for: .normal)
        moreActionsButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        moreActionsButton.showsMenuAsPrimaryAction = true
        moreActionsButton.menu = UIMenu(children: [
            UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in },
            UIAction(title: "Duplicate", image: UIImage(systemName: "plus.square.on.square")) { _ in },
            UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in }
        ])

        usernameField.placeholder = "Username"
        usernameField.borderStyle = .roundedRect
        usernameField.textContentType = .username

        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .password

        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.separator.cgColor
        notesTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        birthDatePicker.datePickerMode = .date
        birthDatePicker.preferredDatePickerStyle = .compact

        openWebsiteButton.setImage(UIImage(systemName: "figure.roll"), for: .normal)
        openWebsiteButton.addAction(UIAction { [weak self] _ in
            guard let url = URL(string: "https://www.apple.com/accessibility/") else { return }
            self?.open(url: url)
        }, for: .touchUpInside)

        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.addAction(UIAction { [weak self] _ in
            guard let url = URL(string: "https://developer.apple.com") else { return }
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self?.present(activityVC, animated: true)
        }, for: .touchUpInside)

        openSettingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        openSettingsButton.addAction(UIAction { [weak self] _ in
            let settingsVC = UIViewController()
            settingsVC.title = "Settings"
            settingsVC.view.backgroundColor = .systemBackground
            self?.navigationController?.pushViewController(settingsVC, animated: true)
        }, for: .touchUpInside)

        favoriteStarButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteStarButton.addAction(UIAction { [weak self] _ in
            self?.toggleFavorite()
        }, for: .touchUpInside)

        deleteAccountButton.setTitle("Delete Account", for: .normal)
        deleteAccountButton.tintColor = .systemRed
        deleteAccountButton.addAction(UIAction { [weak self] _ in
            self?.presentDeleteConfirmation()
        }, for: .touchUpInside)

        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = 10
        quantityStepper.value = 1
        quantityStepper.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.quantity = Int(self.quantityStepper.value)
        }, for: .valueChanged)
        quantityValueLabel.text = "\(quantity)"

        [
            row(title: "Button", control: deleteIconButton),
            row(title: "Toggle", control: notificationsSwitch),
            row(title: "Slider", control: volumeSlider),
            row(title: "Stepper", control: hstack([quantityStepper, quantityValueLabel])),
            row(title: "Segmented Picker", control: colorSegmentedControl),
            row(title: "Menu", control: moreActionsButton),
            row(title: "Text Field", control: usernameField),
            row(title: "Secure Field", control: passwordField),
            row(title: "Text Editor", control: notesTextView),
            row(title: "Date Picker", control: birthDatePicker),
            row(title: "Color Picker", control: favoriteColorWell),
            row(title: "Link", control: openWebsiteButton),
            row(title: "Share", control: shareButton),
            row(title: "Navigation", control: openSettingsButton),
            row(title: "Custom Tappable Icon", control: favoriteStarButton),
            row(title: "Custom Rating Control", control: ratingControl),
            row(title: "Checkbox-style Toggle", control: agreeSwitch),
            row(title: "Confirmation Trigger", control: deleteAccountButton)
        ].forEach { stack.addArrangedSubview($0) }
    }

    private func row(title: String, control: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        let container = UIStackView(arrangedSubviews: [label, control])
        container.axis = .vertical
        container.spacing = 6
        return container
    }

    private func hstack(_ views: [UIView]) -> UIView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }

    private func open(url: URL) {
        UIApplication.shared.open(url)
    }

    private func toggleFavorite() {
        isFavorite.toggle()
        let imageName = isFavorite ? "star.fill" : "star"
        favoriteStarButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteStarButton.accessibilityValue = isFavorite ? "On" : "Off"
    }

    private func presentDeleteConfirmation() {
        let alert = UIAlertController(
            title: "Delete your account?",
            message: "This cannot be undone.",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Accessibility

    private func configureAccessibility() {
        deleteIconButton.accessibilityLabel = "Delete item"
        deleteIconButton.accessibilityHint = "Removes this item from the list"

        notificationsSwitch.accessibilityLabel = "Enable notifications"

        volumeSlider.accessibilityLabel = "Volume"
        volumeSlider.accessibilityValue = "\(Int(volumeSlider.value * 100)) percent"

        quantityStepper.accessibilityLabel = "Quantity"
        quantityStepper.accessibilityValue = "\(quantity)"
        quantityValueLabel.isAccessibilityElement = false // avoid double-announcing

        // Distinct from the colour well below, which is also "Favorite color". Two
        // controls sharing one accessible name is its own defect — a VoiceOver user hears
        // the same words twice with no way to tell which is which — and it only surfaced
        // once NamedColorWell let the well announce its real name instead of "Color".
        colorSegmentedControl.accessibilityLabel = "Preset color"

        moreActionsButton.accessibilityLabel = "More actions"

        usernameField.accessibilityLabel = "Username"
        usernameField.accessibilityHint = "Enter your account username"

        passwordField.accessibilityLabel = "Password"
        passwordField.accessibilityHint = "Enter your account password, minimum 8 characters"

        notesTextView.accessibilityLabel = "Notes"
        notesTextView.accessibilityHint = "Enter any additional notes"

        birthDatePicker.accessibilityLabel = "Date of birth"

        favoriteColorWell.accessibilityLabel = "Favorite color"

        openWebsiteButton.accessibilityLabel = "Open Apple Accessibility website"

        shareButton.accessibilityLabel = "Share this page"

        openSettingsButton.accessibilityLabel = "Open settings"

        favoriteStarButton.accessibilityLabel = "Mark as favorite"
        favoriteStarButton.accessibilityValue = isFavorite ? "On" : "Off"
        favoriteStarButton.accessibilityTraits = .button

        ratingControl.accessibilityLabel = "Rating"

        agreeSwitch.accessibilityLabel = "Agree to Terms of Service"

        deleteAccountButton.accessibilityLabel = "Delete account"
        deleteAccountButton.accessibilityHint = "Permanently deletes your account. This cannot be undone."
    }
}

/// A 5-star tappable rating control exposed to VoiceOver as a single
/// adjustable element, matching the SwiftUI version's
/// `.accessibilityElement(children: .ignore)` + `.accessibilityAdjustableAction`.
final class RatingControl: UIView {

    private(set) var rating = 3 {
        didSet { updateStars() }
    }
    private let maximumRating: Int
    private var starButtons: [UIButton] = []
    private let stack = UIStackView()

    init(maximumRating: Int) {
        self.maximumRating = maximumRating
        super.init(frame: .zero)
        buildStars()
        updateStars()
        configureAccessibility()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildStars() {
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        // The individual stars are implementation detail — this view is the accessible
        // element. UIKit still hands each star an implicit label from its SF Symbol
        // ("favorite"), so without this the scanner sees five identically named buttons
        // that VoiceOver never actually reaches. This is the framework's documented
        // opt-out identifier; the RatingControl container itself is still scanned.
        stack.accessibilityIdentifier = "A11YScannerIgnore"
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        for index in 1...maximumRating {
            let button = UIButton(type: .system).srcLine()
            button.tag = index
            button.isAccessibilityElement = false // grouped into the container instead
            button.addAction(UIAction { [weak self] _ in
                self?.rating = index
            }, for: .touchUpInside)
            starButtons.append(button)
            stack.addArrangedSubview(button)
        }
    }

    private func updateStars() {
        for button in starButtons {
            let filled = button.tag <= rating
            button.setImage(UIImage(systemName: filled ? "star.fill" : "star"), for: .normal)
        }
        accessibilityValue = "\(rating) out of \(maximumRating) stars"
    }

    private func configureAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .adjustable
        accessibilityValue = "\(rating) out of \(maximumRating) stars"
    }

    override func accessibilityIncrement() {
        rating = min(rating + 1, maximumRating)
    }

    override func accessibilityDecrement() {
        rating = max(rating - 1, 1)
    }
}
