import UIKit

/// UIKit equivalent of AccessibleNamePartial. No `accessibilityLabel` is set
/// anywhere. Controls that have a visible *title* or *placeholder* (UIButton,
/// UITextField) still announce something in VoiceOver, because UIKit derives
/// their default accessibilityLabel from that text. But controls with no
/// inherent text — UISwitch, UISlider, UIStepper, UIDatePicker, UIColorWell,
/// UISegmentedControl built from icons — announce only their control type
/// and value ("Switch, off", "Slider, 50%"), with zero context about what
/// they control. A sighted user sees the adjacent UILabel; a VoiceOver user
/// does not, because UIKit never auto-associates a nearby label with a
/// control the way SwiftUI's Toggle/Slider/Picker label parameter does.
final class AccessibleNamePartialViewController: UIViewController {

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
    private let favoriteColorWell = UIColorWell().srcLine()
    private let openWebsiteButton = UIButton(type: .system).srcLine()
    private let shareButton = UIButton(type: .system).srcLine()
    private let openSettingsButton = UIButton(type: .system).srcLine()
    private let favoriteStarButton = UIButton(type: .system).srcLine()
    private let ratingControl = PlainRatingControl(maximumRating: 5).srcLine()
    private let agreeSwitch = UISwitch().srcLine()
    private let deleteAccountButton = UIButton(type: .system).srcLine()

    private var quantity = 1 {
        didSet { quantityValueLabel.text = "\(quantity)" }
    }
    private var isFavorite = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accessible Controls (Partial)"
        view.backgroundColor = .systemBackground
        buildLayout()
        // No configureAccessibility() call — nothing here sets accessibilityLabel.
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

    /// The title label is visible on screen but never wired to the control's
    /// accessibilityLabel — this is the exact bug this file demonstrates.
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
}

/// Same 5-star control as the Pass version, but not grouped or labeled for
/// accessibility — VoiceOver will hit five separate unlabeled "star" buttons
/// in sequence instead of one "Rating" element.
final class PlainRatingControl: UIView {

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
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildStars() {
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
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
    }
}
